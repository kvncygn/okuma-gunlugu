import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/reading_calculator.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/book_cover.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../domain/book.dart';
import '../providers/home_providers.dart';
import 'add_book_sheet.dart';
import 'book_detail_sheet.dart';

/// Kütüphanem & Okuma Listesi bottom sheet bileşeni.
/// Sekmeler: `Okuyorum`, `Okuma Listem`, `Bitenler`
class LibrarySheet extends ConsumerStatefulWidget {
  final BookStatus initialTab;

  const LibrarySheet({
    super.key,
    this.initialTab = BookStatus.reading,
  });

  static Future<void> show(
    BuildContext context, {
    BookStatus initialTab = BookStatus.reading,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => LibrarySheet(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<LibrarySheet> createState() => _LibrarySheetState();
}

class _LibrarySheetState extends ConsumerState<LibrarySheet> {
  late BookStatus _tab = widget.initialTab;

  Future<void> _setAsActiveBook(Book book) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final repo = ref.read(booksRepositoryProvider);
    if (book.status != BookStatus.reading) {
      await repo.updateBook(
        uid,
        book.copyWith(
          status: BookStatus.reading,
          startedAt: book.startedAt ?? DateTime.now(),
        ),
      );
    }
    await repo.updateUserProfile(uid, activeBookId: book.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.show(context, '${book.title} aktif kitap seçildi 📖');
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(homeDashboardProvider);

    return AppBottomSheet(
      child: dashAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.terra),
          ),
        ),
        error: (e, _) => Text('Hata: $e'),
        data: (dash) {
          final books = switch (_tab) {
            BookStatus.reading => dash.readingBooks,
            BookStatus.wishlist => dash.wishlistBooks,
            BookStatus.finished => dash.finishedBooks,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kütüphanem', style: AppTypography.sheetTitle),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AddBookSheet.show(context);
                    },
                    icon: const Icon(
                      LucideIcons.plus,
                      size: 16,
                      color: AppColors.terra,
                    ),
                    label: Text(
                      'Yeni Kitap',
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terra,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3 sekme chip'leri
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabChip(
                      label: 'Okuyorum (${dash.readingBooks.length})',
                      active: _tab == BookStatus.reading,
                      onTap: () => setState(() => _tab = BookStatus.reading),
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Okuma Listem (${dash.wishlistBooks.length})',
                      active: _tab == BookStatus.wishlist,
                      onTap: () => setState(() => _tab = BookStatus.wishlist),
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Bitenler (${dash.finishedBooks.length})',
                      active: _tab == BookStatus.finished,
                      onTap: () => setState(() => _tab = BookStatus.finished),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (books.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.sand),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.bookOpen,
                        size: 28,
                        color: AppColors.ink.withOpacity(0.35),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bu bölümde henüz kitap yok.',
                        style: AppTypography.sans(
                          fontSize: 13,
                          color: AppColors.ink.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isActive = dash.activeBook?.id == book.id;
                      final pct = ReadingCalculator.calculatePercentage(
                        book.currentPage,
                        book.totalPages,
                      );

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pop();
                          BookDetailSheet.show(context, book);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? AppColors.terra : AppColors.sand,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              BookCover(
                                bookKey: book.id,
                                title: book.title,
                                coverUrl: book.coverUrl,
                                width: 52,
                                height: 76,
                                borderRadius: 6,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            book.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.serif(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.terra
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'Aktif',
                                              style: AppTypography.sans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.terra,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      '${book.author} · ${book.genre}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.sans(
                                        fontSize: 12,
                                        color: AppColors.ink.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ProgressBar(percentage: pct, height: 6),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${book.currentPage} / ${book.totalPages} sayfa (%$pct)',
                                      style: AppTypography.sans(
                                        fontSize: 11,
                                        color: AppColors.ink.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isActive &&
                                  book.status != BookStatus.finished) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => _setAsActiveBook(book),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        AppColors.terra.withOpacity(0.10),
                                    foregroundColor: AppColors.terra,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    book.status == BookStatus.wishlist
                                        ? 'Başla'
                                        : 'Seç',
                                    style: AppTypography.sans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.terra,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.ink : AppColors.sand,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.sans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
