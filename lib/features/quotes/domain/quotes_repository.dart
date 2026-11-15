import 'quote.dart';

abstract class QuotesRepository {
  Stream<List<Quote>> watchQuotes(String uid);

  Future<void> addQuote(String uid, Quote quote);

  Future<void> updateQuote(String uid, Quote quote);

  Future<void> deleteQuote(String uid, String quoteId);
}
