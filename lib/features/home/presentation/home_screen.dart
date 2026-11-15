import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_utils_tr.dart';
import '../../../core/utils/reading_calculator.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/stat_card.dart';
import '../../auth/presentation/onboarding_sheet.dart';
import '../../quotes/presentation/widgets/quote_form_sheet.dart';
import '../../settings/presentation/settings_sheet.dart';
import '../domain/book.dart';
import 'providers/home_providers.dart';
import 'widgets/add_book_sheet.dart';
import 'widgets/book_detail_sheet.dart';
import 'widgets/library_sheet.dart';
import 'widgets/update_reading_sheet.dart';

/// Mockup'taki `#tab-home` sekmesinin gerçek Firestore verileriyle çalışan karşılığı.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        OnboardingSheet.showIfNeeded(context, ref);
      }
    });
  }

  Future<void> _selectActiveBook(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref
        .read(booksRepositoryProvider)
        .updateUserProfile(uid, activeBookId: book.id);
    if (!context.mounted) return;
    AppToast.show(context, '${book.title} aktif kitap seçildi 📖');
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(homeDashboardProvider);
    final now = DateTime.now();

    return AsyncStateView(
      isLoading: dashAsync.isLoading,
      errorMessage: dashAsync.hasError ? 'Veriler yüklenemedi.' : null,
      onRetry: () => ref.invalidate(homeDashboardProvider),
      child: dashAsync.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        data: (dash) {
          final profile = dash.profile;
          final activeBook = dash.activeBook;

          final goalTotal = math.max(1, profile.yearlyGoal);
          final finishedCount = dash.finishedThisYearCount;
          final goalPct = ReadingCalculator.calculatePercentage(
            finishedCount,
            goalTotal,
          );
          final remainingBooks = math.max(0, goalTotal - finishedCount);
          final daysLeftYear = DateUtilsTr.daysLeftInYear(now);

          final speedStr = dash.weightedReadingSpeed > 0
              ? dash.weightedReadingSpeed.toStringAsFixed(1)
              : '0.0';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Başlık & Seri Rozeti
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateUtilsTr.formatHeaderDate(now),
                            style: AppTypography.sans(
                              fontSize: 14,
                              color: AppColors.ink.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateUtilsTr.greetingForHour(now.hour)}, ${profile.displayName} 👋',
                            style: AppTypography.pageTitle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terra,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '🔥 ${profile.streakCount} Günlük Seri',
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => SettingsSheet.show(context, profile),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.sand),
                              ),
                              child: const Icon(
                                LucideIcons.settings,
                                size: 15,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Yıllık Hedef Kartı (`mt-5 rounded-3xl bg-ink text-cream p-5`)
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => SettingsSheet.show(context, profile),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${now.year} HEDEFİ',
                                  style: AppTypography.sans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: AppColors.cream.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$finishedCount / $goalTotal Kitap',
                                  style: AppTypography.serif(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.cream,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '%$goalPct',
                              style: AppTypography.sans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.terra,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(
                          percentage: goalPct,
                          height: 10,
                          trackColor: Colors.white.withOpacity(0.15),
                          useGradient: true,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remainingBooks > 0
                              ? '$remainingBooks kitap daha · yıl sonuna $daysLeftYear gün'
                              : 'Yıllık hedefini tamamladın! 🎉 · yıl sonuna $daysLeftYear gün',
                          style: AppTypography.sans(
                            fontSize: 11,
                            color: AppColors.cream.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3'lü İstatistik Kartları (`mt-4 grid grid-cols-3 gap-2.5`)
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Bugün Okunan',
                        value: '${dash.todayPagesRead}',
                        unit: 'Sayfa',
                        valueColor: AppColors.terra,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Günlük Ort.',
                        value: '${dash.dailyAverage30d}',
                        unit: 'Sayfa/gün · 30 gün',
                        valueColor: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Okuma Hızı',
                        value: speedStr,
                        unit: 'dk/sayfa',
                        valueColor: AppColors.sage,
                      ),
                    ),
                  ],
                ),

                // Şu An Okuduğun Başlığı + Kütüphanem / Kitap Ekle
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Şu An Okuduğun',
                      style: AppTypography.sectionTitle,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => LibrarySheet.show(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              'Kütüphanem (${dash.allBooks.length})',
                              style: AppTypography.sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.terra,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => AddBookSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terra.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.plus,
                                  size: 13,
                                  color: AppColors.terra,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Kitap',
                                  style: AppTypography.sans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.terra,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Birden fazla aktif okunan kitap varsa hızlı geçiş hapları
                if (dash.readingBooks.length > 1) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: dash.readingBooks.map((b) {
                        final isSelected = activeBook?.id == b.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _selectActiveBook(context, ref, b),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? AppColors.ink : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.ink
                                      : AppColors.sand,
                                ),
                              ),
                              child: Text(
                                b.title,
                                style: AppTypography.sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Aktif Kitap Kartı
                if (activeBook == null)
                  AsyncStateView(
                    isLoading: false,
                    isEmpty: true,
                    emptyTitle: 'Henüz aktif bir kitabın yok',
                    emptySubtitle:
                        'Okumaya başladığın bir kitabı ekleyerek ilerlemeni takip et.',
                    actionLabel: 'Kitap Ekle',
                    onActionTap: () => AddBookSheet.show(context),
                    child: const SizedBox.shrink(),
                  )
                else
                  _ActiveBookCard(
                    book: activeBook,
                    dailyAverage: dash.dailyAverage30d,
                  ),

                // Hızlı Alıntı Ekle Butonu
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => QuoteFormSheet.show(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terra.withOpacity(0.10),
                      foregroundColor: AppColors.terra,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(LucideIcons.quote, size: 16),
                    label: Text(
                      'Hızlı Alıntı Ekle',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terra,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveBookCard extends StatelessWidget {
  final Book book;
  final int dailyAverage;

  const _ActiveBookCard({
    required this.book,
    required this.dailyAverage,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ReadingCalculator.calculatePercentage(
      book.currentPage,
      book.totalPages,
    );
    final remaining = ReadingCalculator.calculateRemainingPages(
      book.currentPage,
      book.totalPages,
    );
    final leftText = ReadingCalculator.formatRemainingText(
      remaining,
      dailyAverage,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sand),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => BookDetailSheet.show(context, book),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  bookKey: book.id,
                  title: book.title,
                  coverUrl: book.coverUrl,
                  width: 96,
                  height: 140,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: AppTypography.serif(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: AppTypography.sans(
                          fontSize: 14,
                          color: AppColors.ink.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: AppTypography.sans(
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                          children: [
                            TextSpan(
                              text: '${book.currentPage}',
                              style: AppTypography.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' / ${book.totalPages} sayfa  '),
                            TextSpan(
                              text: '%$pct',
                              style: AppTypography.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.terra,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProgressBar(
                        percentage: pct,
                        height: 10,
                        useGradient: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        leftText,
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => UpdateReadingSheet.show(context, book),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.cream,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(LucideIcons.bookOpenCheck, size: 16),
              label: Text(
                'Okuma Güncelle',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
