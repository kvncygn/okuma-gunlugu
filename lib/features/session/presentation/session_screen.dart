import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/reading_calculator.dart';
import '../../../core/widgets/app_toast.dart';
import '../../home/presentation/providers/home_providers.dart';
import 'providers/session_providers.dart';
import 'widgets/finish_session_sheet.dart';

/// Mockup'taki `#tab-session` sekmesinin arka plana dayanıklı kronometre
/// ve haftalık okuma grafiğiyle çalışan karşılığı.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama arka plandan döndüğünde zaman damgasından anlık süreyi hemen güncelle
      ref.read(stopwatchProvider.notifier).refreshElapsed();
    }
  }

  void _onFinishTap() {
    final stopwatch = ref.read(stopwatchProvider);
    if (stopwatch.elapsedSeconds < 1) {
      AppToast.show(context, 'Önce kronometreyi çalıştır ⏱️');
      return;
    }

    final dash = ref.read(homeDashboardProvider).valueOrNull;
    final activeBook = dash?.activeBook;
    if (activeBook == null) {
      AppToast.show(context, 'Önce aktif bir kitap seç 📚');
      return;
    }

    // Açıkta çalışan kronometre varsa duraklatıp özet modalını aç
    if (stopwatch.isRunning) {
      ref.read(stopwatchProvider.notifier).toggle();
    }

    final updatedStopwatch = ref.read(stopwatchProvider);
    FinishSessionSheet.show(
      context: context,
      activeBook: activeBook,
      durationSeconds: updatedStopwatch.elapsedSeconds,
      startedAt: updatedStopwatch.firstStartedAt ??
          DateTime.now().subtract(
            Duration(seconds: updatedStopwatch.elapsedSeconds),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stopwatch = ref.watch(stopwatchProvider);
    final dashAsync = ref.watch(homeDashboardProvider);
    final weeklyBars = ref.watch(weeklyReadingChartProvider);

    final activeBookTitle =
        dashAsync.valueOrNull?.activeBook?.title ?? 'Aktif Kitap';

    final maxWeeklyPages = weeklyBars.fold<int>(
      0,
      (maxVal, bar) => math.max(maxVal, bar.pages),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Okuma Seansı',
            style: AppTypography.pageTitle,
          ),
          const SizedBox(height: 2),
          Text(
            'Odaklan, süreni ölç',
            style: AppTypography.sans(
              fontSize: 14,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),

          // Kronometre Koyu Kartı (`rounded-[32px] bg-ink text-cream p-6 text-center relative overflow-hidden`)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(32),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Sağ üst dekoratif daire: `absolute -right-10 -top-10 w-36 h-36 rounded-full bg-terra/25`
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.terra.withOpacity(0.25),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${activeBookTitle.toUpperCase()} · KRONOMETRE',
                        textAlign: TextAlign.center,
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          color: AppColors.cream.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stopwatch.formattedTime,
                        style: AppTypography.serif(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                          height: 1.1,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stopwatch.statusLabel,
                        style: AppTypography.sans(
                          fontSize: 12,
                          color: AppColors.cream.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(stopwatchProvider.notifier).toggle();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.terra,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(
                              stopwatch.isRunning
                                  ? LucideIcons.pause
                                  : LucideIcons.play,
                              size: 16,
                            ),
                            label: Text(
                              stopwatch.buttonLabel,
                              style: AppTypography.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(stopwatchProvider.notifier).reset();
                              if (!context.mounted) return;
                              AppToast.show(context, 'Kronometre sıfırlandı');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.10),
                              foregroundColor: AppColors.cream,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(LucideIcons.rotateCcw, size: 16),
                            label: Text(
                              'Sıfırla',
                              style: AppTypography.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cream,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Seansı Bitir Butonu (`mt-3 w-full py-3.5 rounded-2xl bg-sage text-white`)
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onFinishTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(LucideIcons.flag, size: 16),
              label: Text(
                'Seansı Bitir',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Haftalık Okuma Bölümü
          const SizedBox(height: 24),
          Text(
            'Haftalık Okuma',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.sand),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 144,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyBars.map((bar) {
                      final barHeight = ReadingCalculator.calculateWeeklyBarHeight(
                        bar.pages,
                        maxWeeklyPages,
                        maxBarHeight: 90.0,
                      );

                      return SizedBox(
                        width: 36,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${bar.pages}',
                              style: AppTypography.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: bar.isToday
                                    ? AppColors.terra
                                    : AppColors.ink.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 550),
                              curve: const Cubic(0.2, 0.8, 0.2, 1.0),
                              width: 20,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: bar.isToday
                                    ? AppColors.terra
                                    : AppColors.sage.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bar.dayLabel,
                              style: AppTypography.sans(
                                fontSize: 10,
                                fontWeight: bar.isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: bar.isToday
                                    ? AppColors.terra
                                    : AppColors.ink.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Son 7 günde okunan sayfa',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 11,
                    color: AppColors.ink.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
