import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_recommendation.freezed.dart';
part 'book_recommendation.g.dart';

@freezed
class BookRecommendation with _$BookRecommendation {
  const factory BookRecommendation({
    required String id,
    required String title,
    required String author,
    required String genre,
    required int tier, // 1: Tür Eşleşmesi, 2: Bunu Sevenler, 3: Google Books
    required String infoBadge,
    @Default(250) int totalPages,
    String? googleBooksId,
    String? coverUrl,
    double? averageRating,
  }) = _BookRecommendation;

  factory BookRecommendation.fromJson(Map<String, dynamic> json) =>
      _$BookRecommendationFromJson(json);
}
