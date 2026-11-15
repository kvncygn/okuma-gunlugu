import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/date_utils_tr.dart';
import '../../../../core/utils/reading_calculator.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/firestore_session_repository.dart';
import '../../data/local_session_repository.dart';
import '../../domain/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final isFirebaseConfigured = ref.watch(isFirebaseConfiguredProvider);
  if (!isFirebaseConfigured) {
    final localBooksRepo = ref.watch(localBooksRepositoryProvider);
    return LocalSessionRepository(localBooksRepo);
  }
  final firestore = ref.watch(firestoreProvider);
  final booksRepo = ref.watch(booksRepositoryProvider);
  return FirestoreSessionRepository(firestore, booksRepo);
});

/// Arka plana dayanıklı kronometre durumu.
/// Süre tick sayarak değil, `now - startedAt + accumulatedSeconds` ile hesaplanır.
class StopwatchState {
  final int accumulatedSeconds;
  final bool isRunning;
  final DateTime? startedAt;
  final DateTime? firstStartedAt;
  final int elapsedSeconds;

  const StopwatchState({
    required this.accumulatedSeconds,
    required this.isRunning,
    this.startedAt,
    this.firstStartedAt,
    required this.elapsedSeconds,
  });

  String get formattedTime => ReadingCalculator.formatStopwatch(elapsedSeconds);

  String get buttonLabel {
    if (isRunning) return 'Duraklat';
    if (elapsedSeconds > 0) return 'Devam Et';
    return 'Başlat';
  }

  String get statusLabel =>
      isRunning ? 'Okuma devam ediyor…' : 'Duraklatıldı';
}

class StopwatchNotifier extends StateNotifier<StopwatchState> {
  final SharedPreferences _prefs;
  Timer? _uiRefreshTimer;

  static const _kAccumulated = 'session_timer_accumulated_sec';
  static const _kIsRunning = 'session_timer_is_running';
  static const _kStartedAtMs = 'session_timer_started_at_ms';
  static const _kFirstStartedAtMs = 'session_timer_first_started_at_ms';

  StopwatchNotifier(this._prefs)
      : super(
          const StopwatchState(
            accumulatedSeconds: 0,
            isRunning: false,
            elapsedSeconds: 0,
          ),
        ) {
    _restoreFromStorage();
  }

  void _restoreFromStorage() {
    final accumulated = _prefs.getInt(_kAccumulated) ?? 0;
    final running = _prefs.getBool(_kIsRunning) ?? false;
    final startedMs = _prefs.getInt(_kStartedAtMs);
    final firstMs = _prefs.getInt(_kFirstStartedAtMs);

    final startedAt = startedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(startedMs)
        : null;
    final firstStartedAt = firstMs != null
        ? DateTime.fromMillisecondsSinceEpoch(firstMs)
        : null;

    final elapsed = ReadingCalculator.calculateElapsedSeconds(
      accumulatedSeconds: accumulated,
      isRunning: running,
      startedAt: startedAt,
    );

    state = StopwatchState(
      accumulatedSeconds: accumulated,
      isRunning: running,
      startedAt: startedAt,
      firstStartedAt: firstStartedAt,
      elapsedSeconds: elapsed,
    );

    if (running) {
      _startUiRefreshLoop();
    }
  }

  void _startUiRefreshLoop() {
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => refreshElapsed(),
    );
  }

  /// Uygulama arka plandan döndüğünde veya UI yenilenirken zaman damgasından gerçek süreyi hesaplar.
  void refreshElapsed() {
    final elapsed = ReadingCalculator.calculateElapsedSeconds(
      accumulatedSeconds: state.accumulatedSeconds,
      isRunning: state.isRunning,
      startedAt: state.startedAt,
    );
    if (elapsed != state.elapsedSeconds) {
      state = StopwatchState(
        accumulatedSeconds: state.accumulatedSeconds,
        isRunning: state.isRunning,
        startedAt: state.startedAt,
        firstStartedAt: state.firstStartedAt,
        elapsedSeconds: elapsed,
      );
    }
  }

  Future<void> toggle() async {
    final now = DateTime.now();
    if (state.isRunning) {
      // Duraklat: şu ana kadar geçen süreyi accumulated içine kilitle
      final totalElapsed = ReadingCalculator.calculateElapsedSeconds(
        accumulatedSeconds: state.accumulatedSeconds,
        isRunning: true,
        startedAt: state.startedAt,
        now: now,
      );
      _uiRefreshTimer?.cancel();

      await _prefs.setInt(_kAccumulated, totalElapsed);
      await _prefs.setBool(_kIsRunning, false);
      await _prefs.remove(_kStartedAtMs);

      state = StopwatchState(
        accumulatedSeconds: totalElapsed,
        isRunning: false,
        startedAt: null,
        firstStartedAt: state.firstStartedAt,
        elapsedSeconds: totalElapsed,
      );
    } else {
      // Başlat / Devam Et
      final firstStart = state.firstStartedAt ?? now;
      await _prefs.setInt(_kAccumulated, state.accumulatedSeconds);
      await _prefs.setBool(_kIsRunning, true);
      await _prefs.setInt(_kStartedAtMs, now.millisecondsSinceEpoch);
      await _prefs.setInt(
        _kFirstStartedAtMs,
        firstStart.millisecondsSinceEpoch,
      );

      state = StopwatchState(
        accumulatedSeconds: state.accumulatedSeconds,
        isRunning: true,
        startedAt: now,
        firstStartedAt: firstStart,
        elapsedSeconds: state.accumulatedSeconds,
      );
      _startUiRefreshLoop();
    }
  }

  Future<void> reset() async {
    _uiRefreshTimer?.cancel();
    await _prefs.remove(_kAccumulated);
    await _prefs.remove(_kIsRunning);
    await _prefs.remove(_kStartedAtMs);
    await _prefs.remove(_kFirstStartedAtMs);

    state = const StopwatchState(
      accumulatedSeconds: 0,
      isRunning: false,
      startedAt: null,
      firstStartedAt: null,
      elapsedSeconds: 0,
    );
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    super.dispose();
  }
}

final stopwatchProvider =
    StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StopwatchNotifier(prefs);
});

/// Haftalık Okuma grafiği için son 7 günün verisi (`renderWeek()`).
class WeeklyDayBar {
  final String dayLabel; // 'Pzt', 'Sal', ...
  final String dateKey; // 'yyyy-MM-dd'
  final int pages;
  final bool isToday;

  const WeeklyDayBar({
    required this.dayLabel,
    required this.dateKey,
    required this.pages,
    required this.isToday,
  });
}

final weeklyReadingChartProvider = Provider<List<WeeklyDayBar>>((ref) {
  final logs = ref.watch(readingLogsLast30DaysStreamProvider).valueOrNull ??
      const [];
  final now = DateTime.now();
  final todayKey = DateUtilsTr.toLocalDayKey(now);

  final Map<String, int> totalsByDate = {};
  for (final log in logs) {
    totalsByDate[log.date] = (totalsByDate[log.date] ?? 0) + log.pagesRead;
  }

  // Bugün en sağda (7. sütun, i == 6) olacak şekilde son 7 gün
  return List.generate(7, (index) {
    final dayDate = now.subtract(Duration(days: 6 - index));
    final key = DateUtilsTr.toLocalDayKey(dayDate);
    return WeeklyDayBar(
      dayLabel: DateUtilsTr.shortWeekday(dayDate),
      dateKey: key,
      pages: totalsByDate[key] ?? 0,
      isToday: key == todayKey,
    );
  });
});
