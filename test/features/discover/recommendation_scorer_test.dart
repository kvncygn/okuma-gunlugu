import 'package:flutter_test/flutter_test.dart';
import 'package:okuma_gunlugu/features/discover/domain/recommendation_scorer.dart';
import 'package:okuma_gunlugu/features/home/domain/book.dart';
import 'package:okuma_gunlugu/features/quotes/data/ocr_service.dart';

void main() {
  group('RecommendationScorer & OCR Türkçe Metin Testleri', () {
    const sampleUserBooks = [
      Book(
        id: 'dune',
        title: 'Dune',
        author: 'Frank Herbert',
        genre: 'Bilim Kurgu',
        totalPages: 320,
        currentPage: 184,
        status: BookStatus.reading,
      ),
      Book(
        id: 'orwell',
        title: '1984',
        author: 'George Orwell',
        genre: 'Bilim Kurgu',
        totalPages: 352,
        currentPage: 352,
        status: BookStatus.finished,
      ),
    ];

    test('Kademe 1 Tür Eşleşmesi baskın tür için daha yüksek yüzde üretir', () {
      final sciFiScore = RecommendationScorer.calculateGenreMatchPercent(
        candidateGenre: 'Bilim Kurgu',
        candidateAuthor: 'Stanisław Lem',
        userBooks: sampleUserBooks,
        averageRating: 4.5,
      );
      final philScore = RecommendationScorer.calculateGenreMatchPercent(
        candidateGenre: 'Felsefe',
        candidateAuthor: 'F. Nietzsche',
        userBooks: sampleUserBooks,
        averageRating: 4.5,
      );

      expect(sciFiScore, greaterThan(philScore));
      expect(sciFiScore, inInclusiveRange(80, 97));
    });

    test('Kademe 2 Ortak Filtreleme skoru ve Türkçe ek uyumu doğru çalışır', () {
      final score = RecommendationScorer.calculateCollaborativeOverlapPercent(
        candidateGenre: 'Bilim Kurgu',
        candidateAuthor: 'Ray Bradbury',
        userBooks: sampleUserBooks,
        averageRating: 4.6,
        ratingsCount: 4200,
      );
      expect(score, inInclusiveRange(80, 96));

      expect(
        RecommendationScorer.formatReadersPercentageBadge(92),
        'Okuyucuların %92’si',
      );
      expect(
        RecommendationScorer.formatReadersPercentageBadge(90),
        'Okuyucuların %90’ı',
      );
      expect(
        RecommendationScorer.formatReadersPercentageBadge(88),
        'Okuyucuların %88’i',
      );
      expect(
        RecommendationScorer.formatReadersPercentageBadge(86),
        'Okuyucuların %86’sı',
      );
    });

    test('OCR Türkçe karakter ve satır sonu tireleme temizliği doğru çalışır', () {
      const rawOcr = 'Özgür-\nlük, iki kere ikinin   dört\nettiğini söyleyebilmektir .';
      final cleaned = OcrService.normalizeTurkishOcrText(rawOcr);
      expect(
        cleaned,
        'Özgürlük, iki kere ikinin dört ettiğini söyleyebilmektir.',
      );
    });
  });
}
