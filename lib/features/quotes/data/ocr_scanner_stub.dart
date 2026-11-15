import 'package:image_picker/image_picker.dart';

/// Web platformunda `google_mlkit_text_recognition` (`dart:ffi`) derlenmediği için
/// kullanılan web-uyumlu OCR tarayıcı stub'ı.
Future<String?> platformScanOcrText(
  ImagePicker picker,
  ImageSource source,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 900));
  return 'Umut, en karanlık çölde bile suyun yerini bilen içgüdüdür.';
}
