import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/date_utils_tr.dart';
import '../../../../core/utils/reading_calculator.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../session/domain/reading_session.dart';
import '../../data/firestore_books_repository.dart';
import '../../data/local_books_repository.dart';
import '../../domain/book.dart';
import '../../domain/books_repository.dart';
import '../../domain/reading_log.dart';

final localBooksRepositoryProvider = Provider<LocalBooksRepository>((ref) {
  return LocalBooksRepository();
});

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final isFirebaseConfigured = ref.watch(isFirebaseConfiguredProvider);
  if (!isFirebaseConfigured) {
    return ref.watch(localBooksRepositoryProvider);
  }
  final firestore = ref.watch(firestoreProvider);
  return FirestoreBooksRepository(firestore);
});

/// Kullanıcı oturum açtığında profil belgesinin varlığını garanti eder.
final userProfileInitializerProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return;
  await ref.watch(booksRepositoryProvider).ensureUserProfileInitialized(uid);
});

final userProfileStreamProvider = StreamProvider<UserProfile>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream.value(
      UserProfile(
        uid: 'guest',
        displayName: 'Okur',
        yearlyGoal: 25,
        streakCount: 0,
        createdAt: DateTime.now(),
      ),
    );
  }
  ref.watch(userProfileInitializerProvider);
  return ref.watch(booksRepositoryProvider).watchUserProfile(uid);
});

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(booksRepositoryProvider).watchBooks(uid);
});

final readingLogsLast30DaysStreamProvider =
    StreamProvider<List<ReadingLog>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(booksRepositoryProvider).watchReadingLogsLast30Days(uid);
});

final allSessionsStreamProvider = StreamProvider<List<ReadingSession>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(booksRepositoryProvider).watchAllSessions(uid);
});

class HomeDashboardState {
  final UserProfile profile;
  final Book? activeBook;
  final List<Book> allBooks;
  final List<Book> readingBooks;
  final List<Book> wishlistBooks;
  final List<Book> finishedBooks;
  final int finishedThisYearCount;
  final int todayPagesRead;
  final int dailyAverage30d;
  final double weightedReadingSpeed;

  const HomeDashboardState({
    required this.profile,
    required this.activeBook,
    required this.allBooks,
    required this.readingBooks,
    required this.wishlistBooks,
    required this.finishedBooks,
    required this.finishedThisYearCount,
    required this.todayPagesRead,
    required this.dailyAverage30d,
    required this.weightedReadingSpeed,
  });
}

final homeDashboardProvider = Provider<AsyncValue<HomeDashboardState>>((ref) {
  final profileAsync = ref.watch(userProfileStreamProvider);
  final booksAsync = ref.watch(booksStreamProvider);
  final logsAsync = ref.watch(readingLogsLast30DaysStreamProvider);
  final sessionsAsync = ref.watch(allSessionsStreamProvider);

  if (profileAsync.isLoading || booksAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (profileAsync.hasError) {
    return AsyncValue.error(profileAsync.error!, profileAsync.stackTrace!);
  }
  if (booksAsync.hasError) {
    return AsyncValue.error(booksAsync.error!, booksAsync.stackTrace!);
  }

  final profile = profileAsync.value!;
  final allBooks = booksAsync.value ?? const [];
  final logs = logsAsync.valueOrNull ?? const [];
  final sessions = sessionsAsync.valueOrNull ?? const [];

  final readingBooks =
      allBooks.where((b) => b.status == BookStatus.reading).toList();
  final wishlistBooks =
      allBooks.where((b) => b.status == BookStatus.wishlist).toList();
  final finishedBooks =
      allBooks.where((b) => b.status == BookStatus.finished).toList();

  // Aktif kitabı belirle: önce profile.activeBookId (reading ise), yoksa ilk reading kitap
  Book? activeBook;
  if (profile.activeBookId != null) {
    activeBook = readingBooks
            .where((b) => b.id == profile.activeBookId)
            .firstOrNull ??
        allBooks.where((b) => b.id == profile.activeBookId).firstOrNull;
  }
  activeBook ??= readingBooks.firstOrNull ?? allBooks.firstOrNull;

  final now = DateTime.now();
  final todayKey = DateUtilsTr.toLocalDayKey(now);

  // Bugün okunan toplam sayfa
  final todayPagesRead = logs
      .where((l) => l.date == todayKey)
      .fold<int>(0, (sum, l) => sum + l.pagesRead);

  // Son 30 gün toplam sayfa ve başlangıçtan itibaren geçen gün sayısı (maks 30)
  final total30dPages = logs.fold<int>(0, (sum, l) => sum + l.pagesRead);

  DateTime earliestDate = profile.createdAt ?? now;
  for (final b in allBooks) {
    if (b.startedAt != null && b.startedAt!.isBefore(earliestDate)) {
      earliestDate = b.startedAt!;
    }
  }
  for (final l in logs) {
    final parsed = DateTime.tryParse(l.date);
    if (parsed != null && parsed.isBefore(earliestDate)) {
      earliestDate = parsed;
    }
  }

  final rawDaysSinceStart = now.difference(earliestDate).inDays + 1;
  final daysSinceStart = math.max(1, math.min(30, rawDaysSinceStart));

  final dailyAverage30d = ReadingCalculator.calculateDailyAverage30d(
    total30dPages,
    daysSinceStart: daysSinceStart,
  );

  // Tüm seansların ağırlıklı ortalama okuma hızı (dk/sayfa)
  final weightedSpeed = ReadingCalculator.calculateWeightedReadingSpeed(
    sessions.map(
      (s) => (durationSeconds: s.durationSeconds, pagesRead: s.pagesRead),
    ),
  );

  // Bu yıl bitirilen kitap sayısı
  final finishedThisYearCount = finishedBooks.where((b) {
    if (b.finishedAt == null) return true;
    return b.finishedAt!.year == now.year;
  }).length;

  return AsyncValue.data(
    HomeDashboardState(
      profile: profile,
      activeBook: activeBook,
      allBooks: allBooks,
      readingBooks: readingBooks,
      wishlistBooks: wishlistBooks,
      finishedBooks: finishedBooks,
      finishedThisYearCount: finishedThisYearCount,
      todayPagesRead: todayPagesRead,
      dailyAverage30d: dailyAverage30d,
      weightedReadingSpeed: weightedSpeed,
    ),
  );
});
