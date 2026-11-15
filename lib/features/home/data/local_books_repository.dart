import 'dart:async';
import 'dart:math' as math;
import '../../../core/utils/date_utils_tr.dart';
import '../../../core/utils/reading_calculator.dart';
import '../../auth/domain/user_profile.dart';
import '../../session/domain/reading_session.dart';
import '../domain/book.dart';
import '../domain/books_repository.dart';
import '../domain/reading_log.dart';

/// Firebase API anahtarları henüz girilmediğinde uygulamanın tüm özelliklerini
/// (Okuma Güncelle, Geri Alma, Otomatik Kitap Bitirme, Seans Hızı, Haftalık Grafik)
/// birebir test edebilmek için çalışan yerel bellek içi Repository implementasyonu.
class LocalBooksRepository implements BooksRepository {
  final _profileController = StreamController<UserProfile>.broadcast();
  final _booksController = StreamController<List<Book>>.broadcast();
  final _logsController = StreamController<List<ReadingLog>>.broadcast();
  final _sessionsController =
      StreamController<List<ReadingSession>>.broadcast();

  late UserProfile _profile;
  late List<Book> _books;
  late List<ReadingLog> _logs;
  late List<ReadingSession> _sessions;

  LocalBooksRepository() {
    final now = DateTime.now();
    final todayKey = DateUtilsTr.toLocalDayKey(now);

    _profile = UserProfile(
      uid: 'local_user',
      displayName: 'Okur',
      yearlyGoal: 25,
      streakCount: 6,
      lastReadDate: todayKey,
      activeBookId: 'dune',
      createdAt: now.subtract(const Duration(days: 29)),
    );

    _books = [
      Book(
        id: 'dune',
        title: 'Dune',
        author: 'Frank Herbert',
        genre: 'Bilim Kurgu',
        totalPages: 320,
        currentPage: 184,
        status: BookStatus.reading,
        startedAt: now.subtract(const Duration(days: 10)),
      ),
      Book(
        id: 'inst',
        title: 'Saatleri Ayarlama Enstitüsü',
        author: 'A. H. Tanpınar',
        genre: 'Klasikler',
        totalPages: 384,
        currentPage: 384,
        status: BookStatus.finished,
        startedAt: now.subtract(const Duration(days: 25)),
        finishedAt: now.subtract(const Duration(days: 12)),
      ),
      Book(
        id: 'orwell',
        title: '1984',
        author: 'George Orwell',
        genre: 'Bilim Kurgu',
        totalPages: 352,
        currentPage: 352,
        status: BookStatus.finished,
        startedAt: now.subtract(const Duration(days: 40)),
        finishedAt: now.subtract(const Duration(days: 26)),
      ),
      Book(
        id: 'kurk',
        title: 'Kürk Mantolu Madonna',
        author: 'Sabahattin Ali',
        genre: 'Klasikler',
        totalPages: 160,
        currentPage: 160,
        status: BookStatus.finished,
        startedAt: now.subtract(const Duration(days: 50)),
        finishedAt: now.subtract(const Duration(days: 42)),
      ),
    ];

    // Mockup'taki son 7 gün verisi: [20, 35, 42, 18, 30, 48, 42 (bugün)]
    const sampleWeekPages = [20, 35, 42, 18, 30, 48, 42];
    _logs = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateKey = DateUtilsTr.toLocalDayKey(date);
      return ReadingLog(
        id: '${dateKey}_dune',
        bookId: 'dune',
        date: dateKey,
        pagesRead: sampleWeekPages[i],
        source: ReadingLogSource.manual,
      );
    });

    // Mockup'taki 1.4 dk/sayfa başlangıç hızını veren örnek seans
    _sessions = [
      ReadingSession(
        id: 'initial_session',
        bookId: 'dune',
        durationSeconds: 2052, // 34.2 dk
        pagesRead: 24, // 34.2 / 24 = 1.425 -> 1.4 dk/sayfa
        minutesPerPage: 1.4,
        startedAt: now.subtract(const Duration(hours: 2)),
        endedAt: now.subtract(const Duration(hours: 1, minutes: 26)),
      ),
    ];
  }

  void _emitAll() {
    _profileController.add(_profile);
    _booksController.add(List.unmodifiable(_books));
    _logsController.add(List.unmodifiable(_logs));
    _sessionsController.add(List.unmodifiable(_sessions));
  }

  void addSessionRecord(ReadingSession session) {
    _sessions = [session, ..._sessions];
    _sessionsController.add(List.unmodifiable(_sessions));
  }

  @override
  Stream<UserProfile> watchUserProfile(String uid) async* {
    yield _profile;
    yield* _profileController.stream;
  }

  @override
  Future<void> ensureUserProfileInitialized(String uid) async {
    _emitAll();
  }

  @override
  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    int? yearlyGoal,
    String? activeBookId,
  }) async {
    _profile = _profile.copyWith(
      displayName: displayName ?? _profile.displayName,
      yearlyGoal: yearlyGoal ?? _profile.yearlyGoal,
      activeBookId: activeBookId ?? _profile.activeBookId,
    );
    _profileController.add(_profile);
  }

  @override
  Stream<List<Book>> watchBooks(String uid) async* {
    yield List.unmodifiable(_books);
    yield* _booksController.stream;
  }

  @override
  Future<String> addBook(
    String uid,
    Book book, {
    bool setAsActive = false,
  }) async {
    final newId = book.id.isNotEmpty
        ? book.id
        : 'book_${DateTime.now().millisecondsSinceEpoch}';
    final saved = book.copyWith(
      id: newId,
      startedAt: book.startedAt ?? DateTime.now(),
    );
    _books = [saved, ..._books.where((b) => b.id != newId)];
    if (setAsActive) {
      _profile = _profile.copyWith(activeBookId: newId);
      _profileController.add(_profile);
    }
    _booksController.add(List.unmodifiable(_books));
    return newId;
  }

  @override
  Future<void> updateBook(String uid, Book book) async {
    _books = _books.map((b) => b.id == book.id ? book : b).toList();
    _booksController.add(List.unmodifiable(_books));
  }

  @override
  Future<void> deleteBook(String uid, String bookId) async {
    _books = _books.where((b) => b.id != bookId).toList();
    _booksController.add(List.unmodifiable(_books));
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
    final logId = '${todayKey}_${book.id}';

    final existingIdx = _logs.indexWhere((l) => l.date == todayKey);
    final currentTodayPages =
        existingIdx >= 0 ? _logs[existingIdx].pagesRead : 0;
    final updatedTodayPages = ReadingCalculator.applyDeltaToTodayPages(
      currentTodayPages,
      delta,
    );

    final updatedLog = ReadingLog(
      id: logId,
      bookId: book.id,
      date: todayKey,
      pagesRead: updatedTodayPages,
      source: source,
    );

    if (existingIdx >= 0) {
      _logs[existingIdx] = updatedLog;
    } else {
      _logs.add(updatedLog);
    }

    final updatedBook = book.copyWith(
      currentPage: clampedNewPage,
      status: autoFinished ? BookStatus.finished : book.status,
      finishedAt: autoFinished ? (book.finishedAt ?? now) : book.finishedAt,
    );
    _books = _books.map((b) => b.id == book.id ? updatedBook : b).toList();

    if (delta > 0) {
      final nextStreak = ReadingCalculator.calculateUpdatedStreak(
        currentStreak: _profile.streakCount,
        lastReadDate: _profile.lastReadDate,
        todayDate: todayKey,
      );
      _profile = _profile.copyWith(
        streakCount: math.max(1, nextStreak),
        lastReadDate: todayKey,
      );
    }

    _emitAll();

    return PageUpdateResult(
      oldPage: oldPage,
      newPage: clampedNewPage,
      delta: delta,
      autoFinished: autoFinished && book.status != BookStatus.finished,
    );
  }

  @override
  Stream<List<ReadingLog>> watchReadingLogsLast30Days(String uid) async* {
    yield List.unmodifiable(_logs);
    yield* _logsController.stream;
  }

  @override
  Stream<List<ReadingSession>> watchAllSessions(String uid) async* {
    yield List.unmodifiable(_sessions);
    yield* _sessionsController.stream;
  }
}
