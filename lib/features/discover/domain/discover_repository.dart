import '../../home/domain/book.dart';
import 'book_recommendation.dart';

class TieredRecommendations {
  final String dominantGenre;
  final String basedOnBooksSubtitle;
  final List<BookRecommendation> tier1GenreMatch;
  final List<BookRecommendation> tier2ReadersAlsoRead;
  final List<BookRecommendation> tier3GoogleBooksOnline;

  const TieredRecommendations({
    required this.dominantGenre,
    required this.basedOnBooksSubtitle,
    required this.tier1GenreMatch,
    required this.tier2ReadersAlsoRead,
    required this.tier3GoogleBooksOnline,
  });
}

/// Keşfet öneri havuzu soyut arayüzü.
///
/// TODO(cloud-functions-collab-filtering):
/// İleride kullanıcı sayısı arttığında 2. kademe ("Bunu Sevenler Şunları da Okudu")
/// önerileri için `CloudFunctionsDiscoverRepository` implementasyonu yazılarak
/// Firebase Cloud Functions üzerindeki gerçek kullanıcı-kitap ortak geçiş matrisi
/// (`getCollaborativeRecommendations` callable function) ile değiştirilecektir.
abstract class DiscoverRepository {
  Future<TieredRecommendations> fetchRecommendations({
    required String selectedGenre,
    required List<Book> userBooks,
  });
}
