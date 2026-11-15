import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

enum BookStatus {
  @JsonValue('reading')
  reading,
  @JsonValue('finished')
  finished,
  @JsonValue('wishlist')
  wishlist,
}

@freezed
class Book with _$Book {
  const factory Book({
    required String id,
    required String title,
    required String author,
    @Default('Roman') String genre,
    @Default(100) int totalPages,
    @Default(0) int currentPage,
    @Default(BookStatus.reading) BookStatus status,
    String? googleBooksId,
    String? coverUrl,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}
