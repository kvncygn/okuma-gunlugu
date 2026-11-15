import 'dart:math' as math;
import '../../home/domain/book.dart';

/// Keşfet sekmesindeki 1. ve 2. kademe öneri yüzdelerini sabit/uydurma sayılar yerine
/// kullanıcının kütüphanesi ve Google Books meta verilerinden hesaplayan saf Dart sınıfı.
class RecommendationScorer {
  RecommendationScorer._();

  /// Kademe 1 ("Tür Eşleşmesi") skoru:
  /// Kullanıcının kütüphanesindeki tür ağırlığı (`genreRatio`), kitabın Google Books puanı
  /// (`averageRating`) ve yazar tanıdıklığından `[80, 97]` aralığında bir yüzde üretir.
  static int calculateGenreMatchPercent({
    required String candidateGenre,
    required String candidateAuthor,
    required List<Book> userBooks,
    double? averageRating,
  }) {
    final activeAndFinished = userBooks
        .where((b) => b.status != BookStatus.wishlist)
        .toList();
    final sourceBooks =
        activeAndFinished.isNotEmpty ? activeAndFinished : userBooks;

    double genreRatio = 0.5;
    bool sameAuthor = false;

    if (sourceBooks.isNotEmpty) {
      final matchingGenreCount = sourceBooks
          .where((b) => b.genre.toLowerCase() == candidateGenre.toLowerCase())
          .length;
      genreRatio = matchingGenreCount / sourceBooks.length;

      sameAuthor = sourceBooks.any(
        (b) => b.author.toLowerCase() == candidateAuthor.toLowerCase(),
      );
    }

    final normalizedRating =
        ((averageRating ?? 4.2).clamp(3.0, 5.0) - 3.0) / 2.0; // 0.0 .. 1.0
    final authorBonus = sameAuthor ? 4.0 : 0.0;

    final rawScore =
        79.0 + (genreRatio * 9.0) + (normalizedRating * 6.0) + authorBonus;
    return rawScore.round().clamp(80, 97);
  }

  /// Kademe 2 ("Bunu Sevenler Şunları da Okudu") skoru:
  ///
  /// FORMÜL AÇIKLAMASI:
  /// Gerçek çok kullanıcılı ortak filtreleme (collaborative filtering) Cloud Function
  /// katmanına geçene kadar, bir kitabın benzer okurlar tarafından beğenilme olasılığı
  /// şu 3 bileşenin ağırlıklı toplamından türetilir:
  /// 1. `ratingQuality` (0..1): Google Books `averageRating` (3.0..5.0 aralığında normalize edilir) -> maks +11 puan
  /// 2. `popularityFactor` (0..1): `log(ratingsCount + 1) / log(5000)` ile popülerlik güven skoru -> maks +6 puan
  /// 3. `libraryAffinity` (0..1): Kullanıcının okuduğu kitaplarla tür eşleşmesi (+0.6) ve
  ///    yazar/başlık anahtar kelime yakınlığı (+0.4) -> maks +5 puan
  /// Taban skor 76 olup sonuç `[80, 96]` aralığına yuvarlanır.
  static int calculateCollaborativeOverlapPercent({
    required String candidateGenre,
    required String candidateAuthor,
    required List<Book> userBooks,
    double? averageRating,
    int? ratingsCount,
  }) {
    final ratingQuality =
        ((averageRating ?? 4.3).clamp(3.0, 5.0) - 3.0) / 2.0; // 0.0 .. 1.0

    final safeCount = math.max(10, ratingsCount ?? 220);
    final popularityFactor =
        (math.log(safeCount + 1) / math.log(5000)).clamp(0.0, 1.0);

    double affinity = 0.3;
    if (userBooks.isNotEmpty) {
      final hasGenreMatch = userBooks.any(
        (b) => b.genre.toLowerCase() == candidateGenre.toLowerCase(),
      );
      final hasAuthorMatch = userBooks.any(
        (b) => b.author.toLowerCase() == candidateAuthor.toLowerCase(),
      );
      affinity = (hasGenreMatch ? 0.6 : 0.2) + (hasAuthorMatch ? 0.4 : 0.0);
    }

    final rawScore = 76.0 +
        (ratingQuality * 11.0) +
        (popularityFactor * 6.0) +
        (affinity * 5.0);
    return rawScore.round().clamp(80, 96);
  }

  /// Türkçe ses uyumuna göre `"Okuyucuların %92’si"`, `"Okuyucuların %90’ı"` etiketini üretir.
  static String formatReadersPercentageBadge(int percentage) {
    final suffix = _turkishPercentageSuffix(percentage);
    return 'Okuyucuların %$percentage’$suffix';
  }

  static String _turkishPercentageSuffix(int number) {
    final lastDigit = number % 10;
    switch (lastDigit) {
      case 1:
      case 5:
      case 8:
        return 'i';
      case 2:
      case 7:
        return 'si';
      case 3:
      case 4:
        return 'ü';
      case 6:
        return 'sı';
      case 9:
        return 'u';
      case 0:
        final tens = (number % 100) ~/ 10;
        if (tens == 1 || tens == 3) return 'u';
        if (tens == 2 || tens == 5) return 'si';
        if (tens == 4 || tens == 6 || tens == 9) return 'ı';
        if (tens == 7 || tens == 8) return 'i';
        return 'ü';
      default:
        return 'i';
    }
  }
}
