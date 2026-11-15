import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/quote_card.dart';
import '../../home/domain/book.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../domain/quote.dart';
import 'providers/quotes_providers.dart';
import 'widgets/quote_form_sheet.dart';
import 'widgets/story_share_sheet.dart';

/// Mockup'taki `#tab-quotes` sekmesinin gerçek Firestore, OCR ve Story paylaşımıyla çalışan karşılığı.
class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  Future<void> _deleteQuote(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    await ref.read(quotesRepositoryProvider).deleteQuote(uid, quote.id);
    if (!context.mounted) return;
    AppToast.show(context, 'Alıntı silindi');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesStreamProvider);
    final books = ref.watch(booksStreamProvider).valueOrNull ?? const <Book>[];

    final Map<String, Book> booksById = {
      for (final b in books) b.id: b,
    };

    final count = quotesAsync.valueOrNull?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık & + Butonu (`flex items-center justify-between`)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alıntılarım', style: AppTypography.pageTitle),
                  const SizedBox(height: 2),
                  Text(
                    '$count kayıtlı alıntı',
                    style: AppTypography.sans(
                      fontSize: 14,
                      color: AppColors.ink.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Material(
                color: AppColors.terra,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: AppColors.terra.withOpacity(0.35),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => QuoteFormSheet.show(context),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Icon(
                        LucideIcons.plus,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          AsyncStateView(
            isLoading: quotesAsync.isLoading,
            errorMessage: quotesAsync.hasError ? 'Alıntılar yüklenemedi.' : null,
            onRetry: () => ref.invalidate(quotesStreamProvider),
            isEmpty: !quotesAsync.isLoading &&
                (quotesAsync.valueOrNull?.isEmpty ?? true),
            emptyTitle: 'Henüz kayıtlı bir alıntın yok',
            emptySubtitle:
                'Kitaplardan sevdiğin cümleleri yazarak ya da kamerayla tarayarak (OCR) biriktir.',
            actionLabel: 'İlk Alıntını Ekle',
            onActionTap: () => QuoteFormSheet.show(context),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quotesAsync.valueOrNull?.length ?? 0,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quote = quotesAsync.value![index];
                final book = booksById[quote.bookId];
                final bookTitle = book?.title ?? quote.bookId;
                final bookAuthor = book?.author ?? '';

                return QuoteCard(
                  text: quote.text,
                  note: quote.note,
                  page: quote.page,
                  bookTitle: bookTitle,
                  bookAuthor: bookAuthor,
                  onEditTap: () => QuoteFormSheet.show(
                    context,
                    existingQuote: quote,
                  ),
                  onDeleteTap: () => _deleteQuote(context, ref, quote),
                  onShareTap: () => StoryShareSheet.show(
                    context,
                    quote: quote,
                    book: book,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
