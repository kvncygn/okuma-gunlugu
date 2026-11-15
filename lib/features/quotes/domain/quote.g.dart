// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      page: (json['page'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      note: json['note'] as String? ?? '',
      source: $enumDecodeNullable(_$QuoteSourceEnumMap, json['source']) ??
          QuoteSource.manual,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'page': instance.page,
      'text': instance.text,
      'note': instance.note,
      'source': _$QuoteSourceEnumMap[instance.source]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$QuoteSourceEnumMap = {
  QuoteSource.manual: 'manual',
  QuoteSource.ocr: 'ocr',
};
