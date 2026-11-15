import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/quote.dart';
import '../domain/quotes_repository.dart';

class FirestoreQuotesRepository implements QuotesRepository {
  final FirebaseFirestore _firestore;

  FirestoreQuotesRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _quotesCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('quotes');

  @override
  Stream<List<Quote>> watchQuotes(String uid) {
    return _quotesCol(uid).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Quote.fromJson({...data, 'id': doc.id});
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> addQuote(String uid, Quote quote) async {
    final docRef = quote.id.isNotEmpty
        ? _quotesCol(uid).doc(quote.id)
        : _quotesCol(uid).doc();
    final saved = quote.copyWith(id: docRef.id);
    await docRef.set(saved.toJson());
  }

  @override
  Future<void> updateQuote(String uid, Quote quote) async {
    await _quotesCol(uid)
        .doc(quote.id)
        .set(quote.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteQuote(String uid, String quoteId) async {
    await _quotesCol(uid).doc(quoteId).delete();
  }
}
