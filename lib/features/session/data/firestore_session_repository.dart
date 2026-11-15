import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/reading_calculator.dart';
import '../../home/domain/book.dart';
import '../../home/domain/books_repository.dart';
import '../../home/domain/reading_log.dart';
import '../domain/reading_session.dart';
import '../domain/session_repository.dart';

class FirestoreSessionRepository implements SessionRepository {
  final FirebaseFirestore _firestore;
  final BooksRepository _booksRepository;

  FirestoreSessionRepository(this._firestore, this._booksRepository);

  CollectionReference<Map<String, dynamic>> _sessionsCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('sessions');

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

    final docRef = _sessionsCol(uid).doc();
    final session = ReadingSession(
      id: docRef.id,
      bookId: activeBook.id,
      durationSeconds: durationSeconds,
      pagesRead: pagesRead,
      minutesPerPage: double.parse(mpp.toStringAsFixed(2)),
      startedAt: startedAt,
      endedAt: endedAt,
    );

    // 1. Seans belgesini kaydet
    await docRef.set(session.toJson());

    // 2. Kitap sayfasını, bugünkü okuma logunu ve seriyi (streak) güncelle
    final targetPage = math.min(
      activeBook.totalPages,
      activeBook.currentPage + pagesRead,
    );

    await _booksRepository.updateReadingProgress(
      uid: uid,
      book: activeBook,
      newPage: targetPage,
      source: ReadingLogSource.session,
    );
  }
}
