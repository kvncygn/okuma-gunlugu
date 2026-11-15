import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/firestore_quotes_repository.dart';
import '../../data/local_quotes_repository.dart';
import '../../data/ocr_service.dart';
import '../../domain/quote.dart';
import '../../domain/quotes_repository.dart';

final quotesRepositoryProvider = Provider<QuotesRepository>((ref) {
  final isFirebaseConfigured = ref.watch(isFirebaseConfiguredProvider);
  if (!isFirebaseConfigured) {
    return LocalQuotesRepository();
  }
  final firestore = ref.watch(firestoreProvider);
  return FirestoreQuotesRepository(firestore);
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

final quotesStreamProvider = StreamProvider<List<Quote>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(quotesRepositoryProvider).watchQuotes(uid);
});
