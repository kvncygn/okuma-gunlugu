import '../../home/domain/book.dart';

abstract class SessionRepository {
  Future<void> saveCompletedSession({
    required String uid,
    required Book activeBook,
    required int durationSeconds,
    required int pagesRead,
    required DateTime startedAt,
    required DateTime endedAt,
  });
}
