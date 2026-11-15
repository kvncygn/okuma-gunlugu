// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_recommendation.dart';

_$BookRecommendationImpl _$$BookRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$BookRecommendationImpl(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      genre: json['genre'] as String? ?? 'Roman',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      infoBadge: json['infoBadge'] as String? ?? '',
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 250,
      googleBooksId: json['googleBooksId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$BookRecommendationImplToJson(
        _$BookRecommendationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'genre': instance.genre,
      'tier': instance.tier,
      'infoBadge': instance.infoBadge,
      'totalPages': instance.totalPages,
      'googleBooksId': instance.googleBooksId,
      'coverUrl': instance.coverUrl,
      'averageRating': instance.averageRating,
    };
