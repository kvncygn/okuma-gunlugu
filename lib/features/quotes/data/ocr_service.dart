import 'package:image_picker/image_picker.dart';
import 'ocr_scanner_stub.dart'
    if (dart.library.io) 'ocr_scanner_io.dart';

/// Kitap sayfasından gerçek OCR ile metin okuma ve Türkçe karakter normalizasyonu servisi.
class OcrService {
  final ImagePicker _picker;

  OcrService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Kameradan veya galeriden fotoğraf alıp ML Kit ile Türkçe metni çıkarır.
  /// Web (Chrome) önizlemesinde `dart:ffi` bağımlılığını dışarıda bırakarak örnek OCR metni döndürür;
  /// iOS ve Android cihazlarda ise gerçek `google_mlkit_text_recognition` çalıştırır.
  Future<String?> scanText({ImageSource source = ImageSource.camera}) async {
    final raw = await platformScanOcrText(_picker, source);
    if (raw == null) return null;
    final cleaned = normalizeTurkishOcrText(raw);
    return cleaned.isEmpty ? null : cleaned;
  }

  /// ML Kit tarafından okunan ham metindeki satır sonu tirelemelerini (`-\n`),
  /// fazla boşlukları ve Türkçe karakter bozulmalarını temizler.
  static String normalizeTurkishOcrText(String rawText) {
    if (rawText.trim().isEmpty) return '';

    final result = rawText
        // Satır sonu tire ile bölünmüş Türkçe kelimeleri birleştir: "öz-\ngürlük" -> "özgürlük"
        .replaceAll(RegExp(r'-\s*\r?\n\s*'), '')
        // Tekil satır sonlarını boşluğa çevir
        .replaceAll(RegExp(r'\r?\n+'), ' ')
        // Birden fazla boşluğu tek boşluğa indir
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        // Yaygın OCR birleşik noktalama hatalarını düzelt
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .replaceAll(' ;', ';')
        .replaceAll(' :', ':')
        .trim();

    return result;
  }
}
