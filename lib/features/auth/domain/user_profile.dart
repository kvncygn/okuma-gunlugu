import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    @Default('Okur') String displayName,
    @Default(25) int yearlyGoal,
    @Default(0) int streakCount,
    String? lastReadDate,
    String? activeBookId,
    DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
