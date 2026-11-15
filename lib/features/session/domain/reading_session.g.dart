// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session.dart';

_$ReadingSessionImpl _$$ReadingSessionImplFromJson(Map<String, dynamic> json) =>
    _$ReadingSessionImpl(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      pagesRead: (json['pagesRead'] as num?)?.toInt() ?? 0,
      minutesPerPage: (json['minutesPerPage'] as num?)?.toDouble() ?? 0.0,
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? '') ??
          DateTime.now(),
    );

Map<String, dynamic> _$$ReadingSessionImplToJson(
        _$ReadingSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'durationSeconds': instance.durationSeconds,
      'pagesRead': instance.pagesRead,
      'minutesPerPage': instance.minutesPerPage,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt.toIso8601String(),
    };
