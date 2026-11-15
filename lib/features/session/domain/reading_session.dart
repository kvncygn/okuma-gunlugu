import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_session.freezed.dart';
part 'reading_session.g.dart';

@freezed
class ReadingSession with _$ReadingSession {
  const factory ReadingSession({
    required String id,
    required String bookId,
    required int durationSeconds,
    required int pagesRead,
    required double minutesPerPage,
    required DateTime startedAt,
    required DateTime endedAt,
  }) = _ReadingSession;

  factory ReadingSession.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionFromJson(json);
}
