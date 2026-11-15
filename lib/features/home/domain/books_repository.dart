import '../../auth/domain/user_profile.dart';
import '../../session/domain/reading_session.dart';
import 'book.dart';
import 'reading_log.dart';

class PageUpdateResult {
  final int oldPage;
  final int newPage;
  final int delta;
  final bool autoFinished;

  const PageUpdateResult({
    required this.oldPage,
    required this.newPage,
    required this.delta,
    required this.autoFinished,
  });
}

abstract class BooksRepository {
  Stream<UserProfile> watchUserProfile(String uid);

  Future<void> ensureUserProfileInitialized(String uid);

  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    int? yearlyGoal,
    String? activeBookId,
  });

  Stream<List<Book>> watchBooks(String uid);

  Future<String> addBook(
    String uid,
    Book book, {
    bool setAsActive = false,
  });

  Future<void> updateBook(String uid, Book book);

  Future<void> deleteBook(String uid, String bookId);

  Future<PageUpdateResult> updateReadingProgress({
    required String uid,
    required Book book,
    required int newPage,
    ReadingLogSource source = ReadingLogSource.manual,
  });

  Stream<List<ReadingLog>> watchReadingLogsLast30Days(String uid);

  Stream<List<ReadingSession>> watchAllSessions(String uid);
}
