// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

mixin _$UserProfile {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  int get yearlyGoal => throw _privateConstructorUsedError;
  int get streakCount => throw _privateConstructorUsedError;
  String? get lastReadDate => throw _privateConstructorUsedError;
  String? get activeBookId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String uid,
      String displayName,
      int yearlyGoal,
      int streakCount,
      String? lastReadDate,
      String? activeBookId,
      DateTime? createdAt});
}

class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? yearlyGoal = null,
    Object? streakCount = null,
    Object? lastReadDate = freezed,
    Object? activeBookId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid ? _value.uid : uid as String,
      displayName: null == displayName ? _value.displayName : displayName as String,
      yearlyGoal: null == yearlyGoal ? _value.yearlyGoal : yearlyGoal as int,
      streakCount: null == streakCount ? _value.streakCount : streakCount as int,
      lastReadDate: freezed == lastReadDate ? _value.lastReadDate : lastReadDate as String?,
      activeBookId: freezed == activeBookId ? _value.activeBookId : activeBookId as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
    ) as $Val);
  }
}

abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String displayName,
      int yearlyGoal,
      int streakCount,
      String? lastReadDate,
      String? activeBookId,
      DateTime? createdAt});
}

class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? yearlyGoal = null,
    Object? streakCount = null,
    Object? lastReadDate = freezed,
    Object? activeBookId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$UserProfileImpl(
      uid: null == uid ? _value.uid : uid as String,
      displayName: null == displayName ? _value.displayName : displayName as String,
      yearlyGoal: null == yearlyGoal ? _value.yearlyGoal : yearlyGoal as int,
      streakCount: null == streakCount ? _value.streakCount : streakCount as int,
      lastReadDate: freezed == lastReadDate ? _value.lastReadDate : lastReadDate as String?,
      activeBookId: freezed == activeBookId ? _value.activeBookId : activeBookId as String?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.uid,
    this.displayName = 'Okur',
    this.yearlyGoal = 25,
    this.streakCount = 0,
    this.lastReadDate,
    this.activeBookId,
    this.createdAt,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String uid;
  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey()
  final int yearlyGoal;
  @override
  @JsonKey()
  final int streakCount;
  @override
  final String? lastReadDate;
  @override
  final String? activeBookId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, yearlyGoal: $yearlyGoal, streakCount: $streakCount, lastReadDate: $lastReadDate, activeBookId: $activeBookId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.yearlyGoal, yearlyGoal) ||
                other.yearlyGoal == yearlyGoal) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            (identical(other.lastReadDate, lastReadDate) ||
                other.lastReadDate == lastReadDate) &&
            (identical(other.activeBookId, activeBookId) ||
                other.activeBookId == activeBookId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uid, displayName, yearlyGoal,
      streakCount, lastReadDate, activeBookId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String uid,
    final String displayName,
    final int yearlyGoal,
    final int streakCount,
    final String? lastReadDate,
    final String? activeBookId,
    final DateTime? createdAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  int get yearlyGoal;
  @override
  int get streakCount;
  @override
  String? get lastReadDate;
  @override
  String? get activeBookId;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
