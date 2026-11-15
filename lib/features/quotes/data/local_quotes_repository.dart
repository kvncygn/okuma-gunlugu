import 'dart:async';
import '../domain/quote.dart';
import '../domain/quotes_repository.dart';

class LocalQuotesRepository implements QuotesRepository {
  final _controller = StreamController<List<Quote>>.broadcast();
  late List<Quote> _quotes;

  LocalQuotesRepository() {
    final now = DateTime.now();
    _quotes = [
      Quote(
        id: '1',
        bookId: 'orwell',
        page: 44,
        text: 'Özgürlük, iki kere ikinin dört ettiğini söyleyebilmektir.',
        note: 'Basit gerçeklere sahip çıkmak bile bir direniş.',
        source: QuoteSource.manual,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Quote(
        id: '2',
        bookId: 'dune',
        page: 12,
        text: 'Korku zihin katilidir.',
        note: 'Sınav günleri için not düştüm.',
        source: QuoteSource.manual,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Quote(
        id: '3',
        bookId: 'kurk',
        page: 96,
        text: 'İnsan en çok, en az beklediği anda kendini ele verir.',
        note: 'Raif Efendi’nin sessizliği hâlâ aklımda.',
        source: QuoteSource.manual,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Quote(
        id: '4',
        bookId: 'inst',
        page: 203,
        text: 'Zaman, ruhun yaşadığı bir evdir; saatler yalnızca kapısındaki zil.',
        note: '',
        source: QuoteSource.manual,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  @override
  Stream<List<Quote>> watchQuotes(String uid) async* {
    yield List.unmodifiable(_quotes);
    yield* _controller.stream;
  }

  @override
  Future<void> addQuote(String uid, Quote quote) async {
    final saved = quote.copyWith(
      id: quote.id.isNotEmpty
          ? quote.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _quotes = [saved, ..._quotes];
    _controller.add(List.unmodifiable(_quotes));
  }

  @override
  Future<void> updateQuote(String uid, Quote quote) async {
    _quotes = _quotes.map((q) => q.id == quote.id ? quote : q).toList();
    _controller.add(List.unmodifiable(_quotes));
  }

  @override
  Future<void> deleteQuote(String uid, String quoteId) async {
    _quotes = _quotes.where((q) => q.id != quoteId).toList();
    _controller.add(List.unmodifiable(_quotes));
  }
}
