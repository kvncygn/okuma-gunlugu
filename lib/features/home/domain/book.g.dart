// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

_$BookImpl _$$BookImplFromJson(Map<String, dynamic> json) => _$BookImpl(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      genre: json['genre'] as String? ?? 'Roman',
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 100,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$BookStatusEnumMap, json['status']) ??
          BookStatus.reading,
      googleBooksId: json['googleBooksId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'].toString()),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.tryParse(json['finishedAt'].toString()),
    );

Map<String, dynamic> _$$BookImplToJson(_$BookImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'genre': instance.genre,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'status': _$BookStatusEnumMap[instance.status]!,
      'googleBooksId': instance.googleBooksId,
      'coverUrl': instance.coverUrl,
      'startedAt': instance.startedAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
    };

const _$BookStatusEnumMap = {
  BookStatus.reading: 'reading',
  BookStatus.finished: 'finished',
  BookStatus.wishlist: 'wishlist',
};
