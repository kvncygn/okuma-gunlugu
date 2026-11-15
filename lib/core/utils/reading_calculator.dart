import 'dart:math' as math;

/// Mockup `<script>` içindeki iş mantığı formüllerinin saf Dart karşılıkları.
class ReadingCalculator {
  ReadingCalculator._();

  /// İlerleme yüzdesi: `Math.round(S.pages / S.total * 100)`
  static int calculatePercentage(int currentPage, int totalPages) {
    if (totalPages <= 0) return 0;
    final clamped = currentPage.clamp(0, totalPages);
    return ((clamped / totalPages) * 100).round();
  }

  /// Kalan sayfa sayısı: `S.total - S.pages`
  static int calculateRemainingPages(int currentPage, int totalPages) {
    if (totalPages <= 0) return 0;
    return math.max(0, totalPages - currentPage);
  }

  /// Son 30 gündeki günlük ortalama sayfa sayısı.
  /// Kullanıcının başlangıç tarihinden itibaren geçen gün sayısına (min 1, maks 30) bölünür.
  static int calculateDailyAverage30d(
    int totalPagesLast30Days, {
    required int daysSinceStart,
  }) {
    if (totalPagesLast30Days <= 0) return 0;
    final divisor = daysSinceStart.clamp(1, 30);
    return (totalPagesLast30Days / divisor).round();
  }

  /// Kalan gün tahmini: `Math.ceil(l / dailyAverage)`
  static int? calculateEstimatedDaysLeft(int remainingPages, int dailyAverage) {
    if (remainingPages <= 0) return 0;
    if (dailyAverage <= 0) return null;
    return (remainingPages / dailyAverage).ceil();
  }

  /// Ana sayfadaki kalan sayfa ve tahmini gün metni:
  /// `l > 0 ? "${l} sayfa kaldı · tahmini ${Math.ceil(l/avg)} gün" : "Kitabı bitirdin! 🎉"`
  static String formatRemainingText(int remainingPages, int dailyAverage) {
    if (remainingPages <= 0) {
      return 'Kitabı bitirdin! 🎉';
    }
    final days = calculateEstimatedDaysLeft(remainingPages, dailyAverage);
    if (days == null) {
      return '$remainingPages sayfa kaldı · henüz ortalama oluşmadı';
    }
    return '$remainingPages sayfa kaldı · tahmini $days gün';
  }

  /// Sayfa girişini `[0, totalPages]` aralığında sınırla (`pmV()`).
  static int clampPage(int value, int totalPages) {
    if (totalPages <= 0) return 0;
    return value.clamp(0, totalPages);
  }

  /// `stepP(n)`: mevcut sayfa girişini `delta` kadar artır/azalt ve sınırla.
  static int stepPage(int currentInput, int delta, int totalPages) {
    return clampPage(currentInput + delta, totalPages);
  }

  /// Okuma Güncelle modalındaki önizleme metni (`pmPrev()`):
  /// `Bugün Okunan = ${v} − ${S.pages} = ${d} sayfa · %${pct}`
  static String formatPageUpdatePreview({
    required int newPage,
    required int oldPage,
    required int totalPages,
  }) {
    final clamped = clampPage(newPage, totalPages);
    final delta = clamped - oldPage;
    final pct = calculatePercentage(clamped, totalPages);
    return 'Bugün Okunan = $clamped − $oldPage = $delta sayfa · %$pct';
  }

  /// Sayfa değişimi (`delta = newPage - oldPage`) bugünkü okuma kaydına uygulanır.
  /// Geri alma (`delta < 0`) durumunda bugünkü kayıttan düşülür (en az 0 olur).
  static int applyDeltaToTodayPages(int currentTodayPages, int delta) {
    return math.max(0, currentTodayPages + delta);
  }

  /// Kitap son sayfaya ulaştığında otomatik bitirme kontrolü.
  static bool shouldAutoFinishBook(int newPage, int totalPages) {
    return totalPages > 0 && newPage >= totalPages;
  }

  /// Kronometre anlık süre hesabı (`now - startedAt + accumulated`).
  /// Uygulama arka plana gitse veya kapansa bile zaman damgasından doğru süreyi üretir.
  static int calculateElapsedSeconds({
    required int accumulatedSeconds,
    required bool isRunning,
    DateTime? startedAt,
    DateTime? now,
  }) {
    if (!isRunning || startedAt == null) {
      return math.max(0, accumulatedSeconds);
    }
    final current = now ?? DateTime.now();
    final diffSeconds = current.difference(startedAt).inSeconds;
    return math.max(0, accumulatedSeconds + math.max(0, diffSeconds));
  }

  /// Kronometre formatı (`fmt(s)` -> `HH:MM:SS`).
  static String formatStopwatch(int totalSeconds) {
    final safeSeconds = math.max(0, totalSeconds);
    final hours = (safeSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((safeSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Tek bir seans için sayfa başına dakika (`(cur() / 60 / n)`).
  static double? calculateSessionMinutesPerPage({
    required int durationSeconds,
    required int pagesRead,
  }) {
    if (pagesRead <= 0 || durationSeconds <= 0) return null;
    return (durationSeconds / 60.0) / pagesRead;
  }

  /// Seans bitirme modalı önizleme metni (`finPrev()`).
  static String formatSessionSummaryPreview({
    required int durationSeconds,
    required int pagesRead,
  }) {
    final mpp = calculateSessionMinutesPerPage(
      durationSeconds: durationSeconds,
      pagesRead: pagesRead,
    );
    if (mpp == null) {
      return 'Okunan sayfa sayısını gir';
    }
    return 'Sayfa başına ${mpp.toStringAsFixed(1)} dakika okudun';
  }

  /// Tüm seansların ağırlıklı ortalama okuma hızı (`dk/sayfa`):
  /// `toplamDakika / toplamSayfa`
  static double calculateWeightedReadingSpeed(
    Iterable<({int durationSeconds, int pagesRead})> sessions,
  ) {
    int totalSeconds = 0;
    int totalPages = 0;
    for (final s in sessions) {
      if (s.durationSeconds > 0 && s.pagesRead > 0) {
        totalSeconds += s.durationSeconds;
        totalPages += s.pagesRead;
      }
    }
    if (totalPages <= 0 || totalSeconds <= 0) return 0.0;
    return (totalSeconds / 60.0) / totalPages;
  }

  /// Haftalık grafik çubuk yüksekliği (`x[1] / mx * maxBarHeight`).
  static double calculateWeeklyBarHeight(
    int pages,
    int maxPages, {
    double maxBarHeight = 90.0,
  }) {
    if (maxPages <= 0 || pages <= 0) return 4.0;
    return (pages / maxPages) * maxBarHeight;
  }

  /// Kitap kapağı gradyan palet indeksi:
  /// `const ci = k => [...k].reduce((s,c) => s + c.charCodeAt(0), 0) % 8`
  static int coverPaletteIndex(String key) {
    if (key.isEmpty) return 0;
    int sum = 0;
    for (final codeUnit in key.codeUnits) {
      sum += codeUnit;
    }
    return sum % 8;
  }

  /// Yerel gün (`yyyy-MM-dd`) bazında okuma serisi (streak) hesabı.
  static int calculateUpdatedStreak({
    required int currentStreak,
    required String? lastReadDate,
    required String todayDate,
  }) {
    if (lastReadDate == null || lastReadDate.isEmpty) {
      return 1;
    }
    if (lastReadDate == todayDate) {
      return math.max(1, currentStreak);
    }
    final last = DateTime.tryParse(lastReadDate);
    final today = DateTime.tryParse(todayDate);
    if (last == null || today == null) {
      return 1;
    }
    final lastDayUtc = DateTime.utc(last.year, last.month, last.day);
    final todayUtc = DateTime.utc(today.year, today.month, today.day);
    final diffDays = todayUtc.difference(lastDayUtc).inDays;

    if (diffDays == 1) {
      return currentStreak + 1;
    } else if (diffDays == 0) {
      return math.max(1, currentStreak);
    } else {
      return 1;
    }
  }
}
