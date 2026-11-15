import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_log.freezed.dart';
part 'reading_log.g.dart';

enum ReadingLogSource {
  @JsonValue('manual')
  manual,
  @JsonValue('session')
  session,
}

@freezed
class ReadingLog with _$ReadingLog {
  const factory ReadingLog({
    required String id,
    required String bookId,
    required String date, // 'yyyy-MM-dd' yerel gün
    required int pagesRead,
    @Default(ReadingLogSource.manual) ReadingLogSource source,
  }) = _ReadingLog;

  factory ReadingLog.fromJson(Map<String, dynamic> json) =>
      _$ReadingLogFromJson(json);
}
