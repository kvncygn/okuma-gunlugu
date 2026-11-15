import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home/domain/book.dart';
import '../domain/book_recommendation.dart';
import '../domain/discover_repository.dart';
import '../domain/recommendation_scorer.dart';

/// Google Books API ve yerel kütüphane analiziyle 3 kademeli öneri üreten implementasyon.
///
/// TODO(cloud-functions-collab-filtering):
/// `tier2ReadersAlsoRead` bölümü şu an Google Books ilişkili yazar/tür sorgusu ve
/// `RecommendationScorer.calculateCollaborativeOverlapPercent` formülüyle çalışmaktadır.
/// Backend'de Cloud Function hazır olduğunda bu sınıf yerine veya hibrit olarak
/// callable Cloud Function bağlanacaktır.
class GoogleBooksDiscoverRepository implements DiscoverRepository {
  final http.Client _client;

  GoogleBooksDiscoverRepository({http.Client? client})
      : _client = client ?? http.Client();

  static const Map<String, String> _genreSubjects = {
    'Bilim Kurgu': 'science+fiction',
    'Felsefe': 'philosophy',
    'Psikoloji': 'psychology',
    'Klasikler': 'classics+literature',
  };

  @override
  Future<TieredRecommendations> fetchRecommendations({
    required String selectedGenre,
    required List<Book> userBooks,
  }) async {
    final dominantGenre = _findDominantGenre(userBooks);
    final targetGenreForTier1 =
        selectedGenre == 'Tümü' ? dominantGenre : selectedGenre;

    final basedOnSubtitle = _buildBasedOnSubtitle(userBooks);

    // 1. Yerel kürasyon + kullanıcı kütüphanesine göre dinamik skorlanan temel katalog
    final curated = _buildScoredCuratedCatalog(userBooks);

    final tier1Curated = curated
        .where(
          (r) => r.tier == 1 && r.genre == targetGenreForTier1,
        )
        .toList();

    final tier2Curated = curated
        .where(
          (r) =>
              r.tier == 2 &&
              (selectedGenre == 'Tümü' || r.genre == selectedGenre),
        )
        .toList();

    // 2. Google Books API'den canlı keşifleri çek
    List<BookRecommendation> tier3Online = await _fetchFromGoogleBooksApi(
      selectedGenre: selectedGenre,
      dominantGenre: dominantGenre,
    );

    if (tier3Online.isEmpty) {
      tier3Online = curated
          .where(
            (r) =>
                r.tier == 3 &&
                (selectedGenre == 'Tümü' || r.genre == selectedGenre),
          )
          .toList();
    }

    return TieredRecommendations(
      dominantGenre: dominantGenre,
      basedOnBooksSubtitle: basedOnSubtitle,
      tier1GenreMatch: tier1Curated,
      tier2ReadersAlsoRead: tier2Curated,
      tier3GoogleBooksOnline: tier3Online,
    );
  }

  String _findDominantGenre(List<Book> userBooks) {
    if (userBooks.isEmpty) return 'Bilim Kurgu';
    final counts = <String, int>{};
    for (final b in userBooks) {
      if (b.status != BookStatus.wishlist) {
        counts[b.genre] = (counts[b.genre] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'Bilim Kurgu';
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String _buildBasedOnSubtitle(List<Book> userBooks) {
    final readOrReading = userBooks
        .where((b) => b.status != BookStatus.wishlist)
        .map((b) => b.title)
        .take(2)
        .toList();
    if (readOrReading.length >= 2) {
      return '${readOrReading[0]} ve ${readOrReading[1]} okuyanların popüler eşleşmeleri';
    } else if (readOrReading.length == 1) {
      return '${readOrReading[0]} ve1984 okuyanların popüler eşleşmeleri'
          .replaceFirst('ve1984', 've 1984');
    }
    return 'Dune ve 1984 okuyanların popüler eşleşmeleri';
  }

  Future<List<BookRecommendation>> _fetchFromGoogleBooksApi({
    required String selectedGenre,
    required String dominantGenre,
  }) async {
    try {
      final queryGenre =
          selectedGenre == 'Tümü' ? dominantGenre : selectedGenre;
      final subject = _genreSubjects[queryGenre] ?? 'fiction';
      const apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');
      final keyParam = apiKey.isNotEmpty ? '&key=$apiKey' : '';

      final uri = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=subject:$subject&langRestrict=tr&maxResults=8&printType=books$keyParam',
      );

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (decoded['items'] as List<dynamic>?) ?? const [];
      if (items.isEmpty) return const [];

      final results = <BookRecommendation>[];
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final info = (item['volumeInfo'] as Map<String, dynamic>?) ?? const {};
        final title = (info['title'] as String?)?.trim() ?? '';
        if (title.isEmpty) continue;

        final authors = (info['authors'] as List<dynamic>?) ?? const [];
        final author = authors.isNotEmpty
            ? authors.first.toString()
            : 'Bilinmeyen Yazar';
        final pageCount = (info['pageCount'] as num?)?.toInt() ?? 320;
        final avgRating = (info['averageRating'] as num?)?.toDouble() ?? 4.4;
        final imageLinks =
            (info['imageLinks'] as Map<String, dynamic>?) ?? const {};
        final coverUrl = (imageLinks['thumbnail'] as String?)
            ?.replaceFirst('http://', 'https://');

        results.add(
          BookRecommendation(
            id: (item['id'] as String?) ?? title.toLowerCase(),
            googleBooksId: item['id'] as String?,
            title: title,
            author: author,
            genre: queryGenre,
            tier: 3,
            infoBadge: '★ ${avgRating.toStringAsFixed(1)} · $pageCount sf.',
            totalPages: pageCount,
            coverUrl: coverUrl,
            averageRating: avgRating,
          ),
        );
      }
      return results;
    } catch (_) {
      return const [];
    }
  }

  List<BookRecommendation> _buildScoredCuratedCatalog(List<Book> userBooks) {
    const rawCatalog = [
      // Tier 1 adayları
      ('solaris', 'Solaris', 'Stanisław Lem', 'Bilim Kurgu', 1, 4.5, 1800, 240),
      ('vakif', 'Vakıf', 'Isaac Asimov', 'Bilim Kurgu', 1, 4.4, 2400, 296),
      ('robot', 'Ben, Robot', 'Isaac Asimov', 'Bilim Kurgu', 1, 4.2, 2100, 256),
      ('zerdust', 'Böyle Buyurdu Zerdüşt', 'F. Nietzsche', 'Felsefe', 1, 4.4, 1900, 352),
      ('bulanti', 'Bulantı', 'J.-P. Sartre', 'Felsefe', 1, 4.1, 1400, 264),
      ('hizli', 'Hızlı ve Yavaş Düşünme', 'D. Kahneman', 'Psikoloji', 1, 4.5, 3200, 512),
      ('frankl', 'İnsanın Anlam Arayışı', 'Viktor Frankl', 'Psikoloji', 1, 4.6, 4100, 176),
      ('karam', 'Karamazov Kardeşler', 'F. Dostoyevski', 'Klasikler', 1, 4.7, 3800, 840),
      ('anna', 'Anna Karenina', 'L. Tolstoy', 'Klasikler', 1, 4.3, 2900, 864),

      // Tier 2 adayları (Bunu Sevenler Şunları da Okudu)
      ('fahren', 'Fahrenheit 451', 'Ray Bradbury', 'Bilim Kurgu', 2, 4.6, 4200, 208),
      ('cesur', 'Cesur Yeni Dünya', 'Aldous Huxley', 'Bilim Kurgu', 2, 4.4, 3900, 272),
      ('hayvan', 'Hayvan Çiftliği', 'George Orwell', 'Klasikler', 2, 4.5, 4500, 152),
      ('yabanci', 'Yabancı', 'Albert Camus', 'Felsefe', 2, 4.4, 3600, 120),

      // Tier 3 adayları (Google Books yedek/başlangıç kataloğu)
      ('neuro', 'Neuromancer', 'William Gibson', 'Bilim Kurgu', 3, 4.2, 1600, 320),
      ('cisim', 'Üç Cisim Problemi', 'Liu Cixin', 'Bilim Kurgu', 3, 4.4, 2800, 400),
      ('atomik', 'Atomik Alışkanlıklar', 'James Clear', 'Psikoloji', 3, 4.6, 5000, 352),
      ('sofie', 'Sofie’nin Dünyası', 'Jostein Gaarder', 'Felsefe', 3, 4.5, 3100, 528),
      ('sefil', 'Sefiller', 'Victor Hugo', 'Klasikler', 3, 4.7, 4700, 1232),
    ];

    return rawCatalog.map((item) {
      final (id, title, author, genre, tier, rating, ratingsCount, pages) = item;

      String badge;
      if (tier == 1) {
        final pct = RecommendationScorer.calculateGenreMatchPercent(
          candidateGenre: genre,
          candidateAuthor: author,
          userBooks: userBooks,
          averageRating: rating,
        );
        badge = '%$pct Tür Eşleşmesi';
      } else if (tier == 2) {
        final pct = RecommendationScorer.calculateCollaborativeOverlapPercent(
          candidateGenre: genre,
          candidateAuthor: author,
          userBooks: userBooks,
          averageRating: rating,
          ratingsCount: ratingsCount,
        );
        badge = RecommendationScorer.formatReadersPercentageBadge(pct);
      } else {
        badge = '★ ${rating.toStringAsFixed(1)} · $pages sf.';
      }

      return BookRecommendation(
        id: id,
        title: title,
        author: author,
        genre: genre,
        tier: tier,
        infoBadge: badge,
        totalPages: pages,
        averageRating: rating,
      );
    }).toList();
  }
}
