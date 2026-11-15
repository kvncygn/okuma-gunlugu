import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// iOS ve Android üzerinde gerçek `google_mlkit_text_recognition` çalıştıran implementasyon.
Future<String?> platformScanOcrText(
  ImagePicker picker,
  ImageSource source,
) async {
  final XFile? image = await picker.pickImage(
    source: source,
    imageQuality: 92,
  );
  if (image == null) return null;

  final inputImage = InputImage.fromFilePath(image.path);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  } finally {
    await textRecognizer.close();
  }
}
