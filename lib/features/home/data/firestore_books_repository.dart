import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/date_utils_tr.dart';
import '../../../core/utils/reading_calculator.dart';
import '../../auth/domain/user_profile.dart';
import '../../session/domain/reading_session.dart';
import '../domain/book.dart';
import '../domain/books_repository.dart';
import '../domain/reading_log.dart';

class FirestoreBooksRepository implements BooksRepository {
  final FirebaseFirestore _firestore;

  FirestoreBooksRepository(this._firestore);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _booksCol(String uid) =>
      _userDoc(uid).collection('books');

  CollectionReference<Map<String, dynamic>> _logsCol(String uid) =>
      _userDoc(uid).collection('readingLogs');

  CollectionReference<Map<String, dynamic>> _sessionsCol(String uid) =>
      _userDoc(uid).collection('sessions');

  @override
  Stream<UserProfile> watchUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) {
        return UserProfile(
          uid: uid,
          displayName: 'Okur',
          yearlyGoal: 25,
          streakCount: 0,
          createdAt: DateTime.now(),
        );
      }
      return UserProfile.fromJson({...data, 'uid': uid});
    });
  }

  @override
  Future<void> ensureUserProfileInitialized(String uid) async {
    final docRef = _userDoc(uid);
    final snap = await docRef.get();
    if (!snap.exists) {
      final now = DateTime.now();
      final todayKey = DateUtilsTr.toLocalDayKey(now);

      // İlk kez açıldığında kullanıcı profilini ve örnek başlangıç kitabını (Dune) oluştur
      const initialBookId = 'dune';
      final initialProfile = UserProfile(
        uid: uid,
        displayName: 'Okur',
        yearlyGoal: 25,
        streakCount: 1,
        lastReadDate: todayKey,
        activeBookId: initialBookId,
        createdAt: now,
      );

      final initialBook = Book(
        id: initialBookId,
        title: 'Dune',
        author: 'Frank Herbert',
        genre: 'Bilim Kurgu',
        totalPages: 320,
        currentPage: 184,
        status: BookStatus.reading,
        startedAt: now.subtract(const Duration(days: 6)),
      );

      final batch = _firestore.batch();
      batch.set(docRef, initialProfile.toJson());
      batch.set(_booksCol(uid).doc(initialBookId), initialBook.toJson());
      await batch.commit();
    }
  }

  @override
  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    int? yearlyGoal,
    String? activeBookId,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName.trim();
    if (yearlyGoal != null) updates['yearlyGoal'] = yearlyGoal.clamp(1, 500);
    if (activeBookId != null) updates['activeBookId'] = activeBookId;
    if (updates.isEmpty) return;

    await _userDoc(uid).set(updates, SetOptions(merge: true));
  }

  @override
  Stream<List<Book>> watchBooks(String uid) {
    return _booksCol(uid).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Book.fromJson({...data, 'id': doc.id});
      }).toList();
      list.sort((a, b) {
        final aDate = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return list;
    });
  }

  @override
  Future<String> addBook(
    String uid,
    Book book, {
    bool setAsActive = false,
  }) async {
    final docRef = book.id.isNotEmpty
        ? _booksCol(uid).doc(book.id)
        : _booksCol(uid).doc();
    final savedBook = book.copyWith(
      id: docRef.id,
      startedAt: book.startedAt ?? DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(docRef, savedBook.toJson());
    if (setAsActive) {
      batch.set(
        _userDoc(uid),
        {'activeBookId': docRef.id},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    return docRef.id;
  }

  @override
  Future<void> updateBook(String uid, Book book) async {
    await _booksCol(uid).doc(book.id).set(book.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBook(String uid, String bookId) async {
    await _booksCol(uid).doc(bookId).delete();
  }

  @override
  Future<PageUpdateResult> updateReadingProgress({
    required String uid,
    required Book book,
    required int newPage,
    ReadingLogSource source = ReadingLogSource.manual,
  }) async {
    final clampedNewPage = ReadingCalculator.clampPage(newPage, book.totalPages);
    final oldPage = book.currentPage;
    final delta = clampedNewPage - oldPage;
    final autoFinished = ReadingCalculator.shouldAutoFinishBook(
      clampedNewPage,
      book.totalPages,
    );

    final now = DateTime.now();
    final todayKey = DateUtilsTr.toLocalDayKey(now);
    final logDocId = '${todayKey}_${book.id}';

    await _firestore.runTransaction((transaction) async {
      final userRef = _userDoc(uid);
      final bookRef = _booksCol(uid).doc(book.id);
      final logRef = _logsCol(uid).doc(logDocId);

      final userSnap = await transaction.get(userRef);
      final logSnap = await transaction.get(logRef);

      // 1. Bugünkü okuma kaydını güncelle (geri almada bugünkü kayıttan düşülür)
      final existingPages = (logSnap.data()?['pagesRead'] as num?)?.toInt() ?? 0;
      final updatedTodayPages = ReadingCalculator.applyDeltaToTodayPages(
        existingPages,
        delta,
      );

      final updatedLog = ReadingLog(
        id: logDocId,
        bookId: book.id,
        date: todayKey,
        pagesRead: updatedTodayPages,
        source: source,
      );
      transaction.set(logRef, updatedLog.toJson());

      // 2. Kitap ilerlemesini ve otomatik bitirme durumunu güncelle
      final updatedBook = book.copyWith(
        currentPage: clampedNewPage,
        status: autoFinished ? BookStatus.finished : book.status,
        finishedAt: autoFinished ? (book.finishedAt ?? now) : book.finishedAt,
      );
      transaction.set(bookRef, updatedBook.toJson(), SetOptions(merge: true));

      // 3. Eğer ileri okuma yapıldıysa (delta > 0) seriyi (streak) güncelle
      if (delta > 0 && userSnap.exists) {
        final userData = userSnap.data()!;
        final currentStreak = (userData['streakCount'] as num?)?.toInt() ?? 0;
        final lastReadDate = userData['lastReadDate'] as String?;

        final nextStreak = ReadingCalculator.calculateUpdatedStreak(
          currentStreak: currentStreak,
          lastReadDate: lastReadDate,
          todayDate: todayKey,
        );

        transaction.set(
          userRef,
          {
            'streakCount': nextStreak,
            'lastReadDate': todayKey,
          },
          SetOptions(merge: true),
        );
      }
    });

    return PageUpdateResult(
      oldPage: oldPage,
      newPage: clampedNewPage,
      delta: delta,
      autoFinished: autoFinished && book.status != BookStatus.finished,
    );
  }

  @override
  Stream<List<ReadingLog>> watchReadingLogsLast30Days(String uid) {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final cutoffKey = DateUtilsTr.toLocalDayKey(cutoffDate);

    return _logsCol(uid)
        .where('date', isGreaterThanOrEqualTo: cutoffKey)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReadingLog.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  @override
  Stream<List<ReadingSession>> watchAllSessions(String uid) {
    return _sessionsCol(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReadingSession.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
}
