import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

enum QuoteSource {
  @JsonValue('manual')
  manual,
  @JsonValue('ocr')
  ocr,
}

@freezed
class Quote with _$Quote {
  const factory Quote({
    required String id,
    required String bookId,
    @Default(0) int page,
    required String text,
    @Default('') String note,
    @Default(QuoteSource.manual) QuoteSource source,
    required DateTime createdAt,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
