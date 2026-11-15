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
import 'update_reading_sheet.dart';

/// Kitap detayı, durum değiştirme ve silme bottom sheet bileşeni.
class BookDetailSheet extends ConsumerWidget {
  final Book book;

  const BookDetailSheet({
    super.key,
    required this.book,
  });

  static Future<void> show(BuildContext context, Book book) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => BookDetailSheet(book: book),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    BookStatus newStatus,
  ) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final repo = ref.read(booksRepositoryProvider);
    final updated = book.copyWith(
      status: newStatus,
      currentPage:
          newStatus == BookStatus.finished ? book.totalPages : book.currentPage,
      finishedAt:
          newStatus == BookStatus.finished ? DateTime.now() : book.finishedAt,
    );

    await repo.updateBook(uid, updated);
    if (newStatus == BookStatus.reading) {
      await repo.updateUserProfile(uid, activeBookId: book.id);
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppToast.show(context, 'Kitap durumu güncellendi ✨');
  }

  Future<void> _deleteBook(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    await ref.read(booksRepositoryProvider).deleteBook(uid, book.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppToast.show(context, '${book.title} silindi');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = ReadingCalculator.calculatePercentage(
      book.currentPage,
      book.totalPages,
    );
    final remaining = ReadingCalculator.calculateRemainingPages(
      book.currentPage,
      book.totalPages,
    );

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                bookKey: book.id,
                title: book.title,
                coverUrl: book.coverUrl,
                width: 88,
                height: 128,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.terra.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        book.genre,
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.terra,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.title,
                      style: AppTypography.serif(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
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
                    Text(
                      '${book.currentPage} / ${book.totalPages} sayfa · %$pct',
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ProgressBar(percentage: pct, height: 8),
                    const SizedBox(height: 4),
                    Text(
                      remaining > 0
                          ? '$remaining sayfa kaldı'
                          : 'Kitap tamamlandı 🎉',
                      style: AppTypography.sans(
                        fontSize: 11,
                        color: AppColors.ink.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Kitap Durumu',
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusButton(
                label: 'Okuyorum',
                active: book.status == BookStatus.reading,
                onTap: () => _changeStatus(context, ref, BookStatus.reading),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Listemde',
                active: book.status == BookStatus.wishlist,
                onTap: () => _changeStatus(context, ref, BookStatus.wishlist),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Bitirdim',
                active: book.status == BookStatus.finished,
                onTap: () => _changeStatus(context, ref, BookStatus.finished),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteBook(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.terra,
                    side: const BorderSide(color: AppColors.sand),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: Text(
                    'Kitabı Sil',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terra,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    UpdateReadingSheet.show(context, book);
                  },
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
                    'Sayfa Güncelle',
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
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.ink : AppColors.sand,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.sans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
