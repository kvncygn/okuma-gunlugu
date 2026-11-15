import 'package:flutter_test/flutter_test.dart';
import 'package:okuma_gunlugu/core/utils/reading_calculator.dart';

void main() {
  group('ReadingCalculator - Mockup Formül Doğrulama Testleri', () {
    test('Yüzde hesabı: 184 / 320 sayfa mockup ile birebir %57 üretir', () {
      // Mockup (JS): Math.round(184 / 320 * 100) -> 184/320*100 = 57.49999999999999
      // (IEEE-754 kayan nokta) -> Math.round = 57. Dart'ta da aynı sonuç çıkar.
      expect(ReadingCalculator.calculatePercentage(184, 320), 57);
      expect(ReadingCalculator.calculatePercentage(12, 25), 48);
      expect(ReadingCalculator.calculatePercentage(0, 320), 0);
      expect(ReadingCalculator.calculatePercentage(320, 320), 100);
      expect(ReadingCalculator.calculatePercentage(400, 320), 100);
    });

    test('Kalan sayfa ve kalan gün tahmini: Math.ceil(l / dailyAvg)', () {
      // Mockup: 320 - 184 = 136 sayfa kaldı, günlük ort 28 -> ceil(136 / 28) = 5 gün
      final remaining = ReadingCalculator.calculateRemainingPages(184, 320);
      expect(remaining, 136);

      final estDays = ReadingCalculator.calculateEstimatedDaysLeft(remaining, 28);
      expect(estDays, 5);

      expect(
        ReadingCalculator.formatRemainingText(136, 28),
        '136 sayfa kaldı · tahmini 5 gün',
      );
      expect(
        ReadingCalculator.formatRemainingText(0, 28),
        'Kitabı bitirdin! 🎉',
      );
      expect(
        ReadingCalculator.formatRemainingText(100, 0),
        '100 sayfa kaldı · henüz ortalama oluşmadı',
      );
    });

    test('30 günlük ortalama: geçen gün sayısına (min 1, maks 30) bölünür', () {
      expect(
        ReadingCalculator.calculateDailyAverage30d(840, daysSinceStart: 30),
        28,
      );
      // 45 gün geçmiş olsa bile maks 30'a bölünür
      expect(
        ReadingCalculator.calculateDailyAverage30d(840, daysSinceStart: 45),
        28,
      );
      // Yeni kullanıcı (5 gündür okuyor, toplam 100 sayfa -> 20 sayfa/gün)
      expect(
        ReadingCalculator.calculateDailyAverage30d(100, daysSinceStart: 5),
        20,
      );
    });

    test('Okuma Güncelle stepP(±10), önizleme metni, geri alma ve otomatik bitirme', () {
      expect(ReadingCalculator.stepPage(184, 10, 320), 194);
      expect(ReadingCalculator.stepPage(184, -10, 320), 174);
      expect(ReadingCalculator.stepPage(5, -10, 320), 0);
      expect(ReadingCalculator.stepPage(315, 10, 320), 320);

      expect(
        ReadingCalculator.formatPageUpdatePreview(
          newPage: 194,
          oldPage: 184,
          totalPages: 320,
        ),
        'Bugün Okunan = 194 − 184 = 10 sayfa · %61',
      );

      // İleri okuma (+10)
      expect(ReadingCalculator.applyDeltaToTodayPages(42, 10), 52);
      // Geri alma (-10): bugünkü kayıttan düşülür
      expect(ReadingCalculator.applyDeltaToTodayPages(42, -10), 32);
      // Negatife düşmez
      expect(ReadingCalculator.applyDeltaToTodayPages(5, -10), 0);

      // Son sayfaya ulaşıldığında otomatik bitirme
      expect(ReadingCalculator.shouldAutoFinishBook(320, 320), isTrue);
      expect(ReadingCalculator.shouldAutoFinishBook(319, 320), isFalse);
    });

    test('Kronometre: now - startedAt + accumulated ve HH:MM:SS formatı', () {
      // Mockup başlangıç değeri: el = 2052 sn -> 00:34:12
      expect(ReadingCalculator.formatStopwatch(2052), '00:34:12');
      expect(ReadingCalculator.formatStopwatch(0), '00:00:00');
      expect(ReadingCalculator.formatStopwatch(3661), '01:01:01');

      final start = DateTime(2026, 11, 15, 20, 0, 0);
      final after90Sec = DateTime(2026, 11, 15, 20, 1, 30);

      final elapsedRunning = ReadingCalculator.calculateElapsedSeconds(
        accumulatedSeconds: 100,
        isRunning: true,
        startedAt: start,
        now: after90Sec,
      );
      expect(elapsedRunning, 190);

      final elapsedPaused = ReadingCalculator.calculateElapsedSeconds(
        accumulatedSeconds: 190,
        isRunning: false,
        startedAt: start,
        now: after90Sec,
      );
      expect(elapsedPaused, 190);
    });

    test('Okuma Hızı: tekil seans ve tüm seansların ağırlıklı ortalaması (dk/sayfa)', () {
      // 2052 sn (34.2 dk) içinde 24 sayfa -> 1.425 dk/sayfa -> "1.4"
      final singleMpp = ReadingCalculator.calculateSessionMinutesPerPage(
        durationSeconds: 2052,
        pagesRead: 24,
      );
      expect(singleMpp, closeTo(1.425, 0.001));
      expect(
        ReadingCalculator.formatSessionSummaryPreview(
          durationSeconds: 2052,
          pagesRead: 24,
        ),
        'Sayfa başına 1.4 dakika okudun',
      );

      // Ağırlıklı ortalama:
      // Seans 1: 1800 sn (30 dk), 20 sayfa
      // Seans 2: 2400 sn (40 dk), 30 sayfa
      // Toplam: 70 dk / 50 sayfa = 1.4 dk/sayfa
      final weighted = ReadingCalculator.calculateWeightedReadingSpeed([
        (durationSeconds: 1800, pagesRead: 20),
        (durationSeconds: 2400, pagesRead: 30),
      ]);
      expect(weighted, closeTo(1.4, 0.001));
    });

    test('Seri (Streak) yerel gün değişimine göre doğru güncellenir', () {
      // Ardışık gün -> streak + 1
      expect(
        ReadingCalculator.calculateUpdatedStreak(
          currentStreak: 6,
          lastReadDate: '2026-11-14',
          todayDate: '2026-11-15',
        ),
        7,
      );

      // Aynı gün tekrar okuma -> streak sabit kalır
      expect(
        ReadingCalculator.calculateUpdatedStreak(
          currentStreak: 6,
          lastReadDate: '2026-11-15',
          todayDate: '2026-11-15',
        ),
        6,
      );

      // Gün atlanmışsa -> 1'den başlar
      expect(
        ReadingCalculator.calculateUpdatedStreak(
          currentStreak: 6,
          lastReadDate: '2026-11-12',
          todayDate: '2026-11-15',
        ),
        1,
      );
    });

    test('Haftalık grafik çubuk yüksekliği ve kapak palet indeksi ci(k)', () {
      expect(
        ReadingCalculator.calculateWeeklyBarHeight(48, 48, maxBarHeight: 90),
        90.0,
      );
      expect(
        ReadingCalculator.calculateWeeklyBarHeight(24, 48, maxBarHeight: 90),
        45.0,
      );

      // 'dune': 100 + 117 + 110 + 101 = 428; 428 % 8 = 4
      expect(ReadingCalculator.coverPaletteIndex('dune'), 4);
    });
  });
}
