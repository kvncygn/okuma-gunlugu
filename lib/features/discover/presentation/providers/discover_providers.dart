import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/google_books_discover_repository.dart';
import '../../domain/discover_repository.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return GoogleBooksDiscoverRepository();
});

final selectedDiscoverGenreProvider = StateProvider<String>((ref) => 'Tümü');

final tieredRecommendationsProvider =
    FutureProvider<TieredRecommendations>((ref) async {
  final selectedGenre = ref.watch(selectedDiscoverGenreProvider);
  final userBooks = ref.watch(booksStreamProvider).valueOrNull ?? const [];
  final repo = ref.watch(discoverRepositoryProvider);

  return repo.fetchRecommendations(
    selectedGenre: selectedGenre,
    userBooks: userBooks,
  );
});
