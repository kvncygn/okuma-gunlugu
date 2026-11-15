import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/book_cover.dart';
import '../../home/domain/book.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../domain/book_recommendation.dart';
import 'providers/discover_providers.dart';

/// Mockup'taki `#tab-discover` sekmesinin 3 kademeli öneri,
/// dinamik skorlama ve Google Books API entegrasyonuyla çalışan karşılığı.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  static const List<String> _genres = [
    'Tümü',
    'Bilim Kurgu',
    'Felsefe',
    'Psikoloji',
    'Klasikler',
  ];

  bool _isAlreadyAdded(BookRecommendation rec, List<Book> userBooks) {
    return userBooks.any(
      (b) =>
          b.id == rec.id ||
          (rec.googleBooksId != null && b.googleBooksId == rec.googleBooksId) ||
          b.title.toLowerCase() == rec.title.toLowerCase(),
    );
  }

  Future<void> _addRecommendationToWishlist(
    BuildContext context,
    WidgetRef ref,
    BookRecommendation rec,
    List<Book> userBooks,
  ) async {
    if (_isAlreadyAdded(rec, userBooks)) {
      AppToast.show(context, 'Zaten listende ✓');
      return;
    }

    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final book = Book(
      id: rec.id,
      title: rec.title,
      author: rec.author,
      genre: rec.genre,
      totalPages: rec.totalPages,
      currentPage: 0,
      status: BookStatus.wishlist,
      googleBooksId: rec.googleBooksId,
      coverUrl: rec.coverUrl,
      startedAt: DateTime.now(),
    );

    await ref.read(booksRepositoryProvider).addBook(uid, book);
    if (!context.mounted) return;
    AppToast.show(context, 'Okuma listene eklendi 📚');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGenre = ref.watch(selectedDiscoverGenreProvider);
    final recsAsync = ref.watch(tieredRecommendationsProvider);
    final userBooks =
        ref.watch(booksStreamProvider).valueOrNull ?? const <Book>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık (`px-5`)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keşfet', style: AppTypography.pageTitle),
                const SizedBox(height: 2),
                Text(
                  'Zevkine göre 3 kademeli öneri',
                  style: AppTypography.sans(
                    fontSize: 14,
                    color: AppColors.ink.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Tür Chip'leri (`#chips mt-4 px-5 flex gap-2 overflow-x-auto`)
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _genres.map((g) {
                final isSelected = g == selectedGenre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      ref.read(selectedDiscoverGenreProvider.notifier).state =
                          g;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.ink : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? AppColors.ink : AppColors.sand,
                        ),
                      ),
                      child: Text(
                        g,
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3 Kademeli Öneri Listeleri
          AsyncStateView(
            isLoading: recsAsync.isLoading,
            errorMessage:
                recsAsync.hasError ? 'Öneriler yüklenirken hata oluştu.' : null,
            onRetry: () => ref.invalidate(tieredRecommendationsProvider),
            child: recsAsync.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (data) {
                final isAll = selectedGenre == 'Tümü';
                final tier1Title = isAll
                    ? 'Son Okuduğun Türlere Göre (${data.dominantGenre})'
                    : '$selectedGenre Seçkisi';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kademe 1: Tür Eşleşmesi
                    _RecommendationSection(
                      title: tier1Title,
                      subtitle: 'Yerel kütüphane analizinden',
                      items: data.tier1GenreMatch,
                      userBooks: userBooks,
                      isAlreadyAdded: _isAlreadyAdded,
                      onAddTap: (rec) => _addRecommendationToWishlist(
                        context,
                        ref,
                        rec,
                        userBooks,
                      ),
                    ),

                    // Kademe 2: Bunu Sevenler Şunları da Okudu
                    _RecommendationSection(
                      title: 'Bunu Sevenler Şunları da Okudu',
                      subtitle: data.basedOnBooksSubtitle,
                      items: data.tier2ReadersAlsoRead,
                      userBooks: userBooks,
                      isAlreadyAdded: _isAlreadyAdded,
                      onAddTap: (rec) => _addRecommendationToWishlist(
                        context,
                        ref,
                        rec,
                        userBooks,
                      ),
                    ),

                    // Kademe 3: Google Books API Keşifleri (ONLINE)
                    _RecommendationSection(
                      title: 'Google Books API Keşifleri',
                      badgeText: 'ONLINE',
                      subtitle: 'Çevrim içi kütüphaneden çekildi',
                      items: data.tier3GoogleBooksOnline,
                      emptyMessage: 'Bu türde sonuç yok.',
                      userBooks: userBooks,
                      isAlreadyAdded: _isAlreadyAdded,
                      onAddTap: (rec) => _addRecommendationToWishlist(
                        context,
                        ref,
                        rec,
                        userBooks,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final String title;
  final String? badgeText;
  final String subtitle;
  final List<BookRecommendation> items;
  final String emptyMessage;
  final List<Book> userBooks;
  final bool Function(BookRecommendation, List<Book>) isAlreadyAdded;
  final ValueChanged<BookRecommendation> onAddTap;

  const _RecommendationSection({
    required this.title,
    this.badgeText,
    required this.subtitle,
    required this.items,
    this.emptyMessage = 'Bu türde henüz öneri yok.',
    required this.userBooks,
    required this.isAlreadyAdded,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.serif(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.sans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subtitle,
            style: AppTypography.sans(
              fontSize: 12,
              color: AppColors.ink.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(
              emptyMessage,
              style: AppTypography.sans(
                fontSize: 14,
                color: AppColors.ink.withOpacity(0.5),
              ),
            ),
          )
        else
          SizedBox(
            height: 284,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final rec = items[index];
                final added = isAlreadyAdded(rec, userBooks);
                return _RecommendationCard(
                  recommendation: rec,
                  isAdded: added,
                  onAddTap: () => onAddTap(rec),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Mockup'taki `card(r)` bileşeni:
/// `w-[160px] rounded-3xl bg-white border border-sand p-3`
class _RecommendationCard extends StatelessWidget {
  final BookRecommendation recommendation;
  final bool isAdded;
  final VoidCallback onAddTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.isAdded,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (recommendation.tier) {
      1 => AppColors.sage,
      2 => AppColors.terra,
      _ => AppColors.ink.withOpacity(0.6),
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: BookCover(
              bookKey: recommendation.id,
              title: recommendation.title,
              coverUrl: recommendation.coverUrl,
              width: 104,
              height: 150,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.serif(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            recommendation.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 12,
              color: AppColors.ink.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Text(
            recommendation.infoBadge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAddTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isAdded
                      ? AppColors.sage
                      : AppColors.terra.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isAdded ? 'Eklendi ✓' : 'Okuma Listeme Ekle',
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isAdded ? Colors.white : AppColors.terra,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
