import 'dart:async';
import 'dart:math' as math;
import '../../../core/utils/reading_calculator.dart';
import '../../home/data/local_books_repository.dart';
import '../../home/domain/book.dart';
import '../../home/domain/reading_log.dart';
import '../domain/reading_session.dart';
import '../domain/session_repository.dart';

class LocalSessionRepository implements SessionRepository {
  final LocalBooksRepository _localBooksRepository;

  LocalSessionRepository(this._localBooksRepository);

  @override
  Future<void> saveCompletedSession({
    required String uid,
    required Book activeBook,
    required int durationSeconds,
    required int pagesRead,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final mpp = ReadingCalculator.calculateSessionMinutesPerPage(
          durationSeconds: durationSeconds,
          pagesRead: pagesRead,
        ) ??
        0.0;

    final session = ReadingSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      bookId: activeBook.id,
      durationSeconds: durationSeconds,
      pagesRead: pagesRead,
      minutesPerPage: double.parse(mpp.toStringAsFixed(2)),
      startedAt: startedAt,
      endedAt: endedAt,
    );

    _localBooksRepository.addSessionRecord(session);

    final targetPage = math.min(
      activeBook.totalPages,
      activeBook.currentPage + pagesRead,
    );

    await _localBooksRepository.updateReadingProgress(
      uid: uid,
      book: activeBook,
      newPage: targetPage,
      source: ReadingLogSource.session,
    );
  }
}
