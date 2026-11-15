// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_log.dart';

_$ReadingLogImpl _$$ReadingLogImplFromJson(Map<String, dynamic> json) =>
    _$ReadingLogImpl(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      pagesRead: (json['pagesRead'] as num?)?.toInt() ?? 0,
      source: $enumDecodeNullable(_$ReadingLogSourceEnumMap, json['source']) ??
          ReadingLogSource.manual,
    );

Map<String, dynamic> _$$ReadingLogImplToJson(_$ReadingLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'date': instance.date,
      'pagesRead': instance.pagesRead,
      'source': _$ReadingLogSourceEnumMap[instance.source]!,
    };

const _$ReadingLogSourceEnumMap = {
  ReadingLogSource.manual: 'manual',
  ReadingLogSource.session: 'session',
};
