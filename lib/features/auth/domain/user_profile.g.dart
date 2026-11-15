// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Okur',
      yearlyGoal: (json['yearlyGoal'] as num?)?.toInt() ?? 25,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      lastReadDate: json['lastReadDate'] as String?,
      activeBookId: json['activeBookId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'yearlyGoal': instance.yearlyGoal,
      'streakCount': instance.streakCount,
      'lastReadDate': instance.lastReadDate,
      'activeBookId': instance.activeBookId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
