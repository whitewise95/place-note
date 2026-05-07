import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'mock_ocr_service.dart';
import 'ocr_service.dart';

class MlKitOcrService implements OcrService {
  MlKitOcrService({OcrService? fallback})
      : _fallback = fallback ?? MockOcrService();

  final OcrService _fallback;

  @override
  Future<String> recognize(String? imagePath) async {
    if (imagePath == null || imagePath == MockOcrSource.sample) {
      return _fallback.recognize(imagePath);
    }

    if (!_isMobilePlatform || !File(imagePath).existsSync()) {
      return _fallback.recognize(imagePath);
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.korean);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      final text = recognizedText.text.trim();

      if (text.isEmpty) {
        throw const OcrException('이미지에서 텍스트를 찾지 못했습니다.');
      }

      return text;
    } catch (error) {
      throw OcrException('OCR 처리에 실패했습니다: $error');
    } finally {
      await recognizer.close();
    }
  }

  bool get _isMobilePlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }
}

class OcrException implements Exception {
  const OcrException(this.message);

  final String message;

  @override
  String toString() => message;
}
