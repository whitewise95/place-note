import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/ocr/mock_ocr_service.dart';

class ImageAttachmentStorage {
  static const int maxStoredImageSide = 1080;
  static const int jpegQuality = 78;

  Future<String?> persist(String? sourcePath) async {
    if (sourcePath == null ||
        sourcePath.isEmpty ||
        sourcePath == MockOcrSource.sample) {
      return sourcePath;
    }

    final source = File(sourcePath);
    if (!source.existsSync()) {
      return sourcePath;
    }

    final documents = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(documents.path, 'place_note_images'));
    if (!imageDir.existsSync()) {
      await imageDir.create(recursive: true);
    }

    final filename = 'capture-${DateTime.now().microsecondsSinceEpoch}.jpg';
    final destination = File(p.join(imageDir.path, filename));

    final storedBytes = await _createStoredImageBytes(source);
    if (storedBytes == null) {
      await source.copy(destination.path);
    } else {
      await destination.writeAsBytes(storedBytes, flush: true);
    }

    return destination.path;
  }

  Future<void> delete(String? imagePath) async {
    if (imagePath == null ||
        imagePath.isEmpty ||
        imagePath == MockOcrSource.sample) {
      return;
    }

    final documents = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(documents.path, 'place_note_images'));
    final file = File(imagePath);

    final isManagedImage = p.equals(file.parent.path, imageDir.path) ||
        p.isWithin(imageDir.path, file.path);
    if (!isManagedImage || !file.existsSync()) {
      return;
    }

    await file.delete();
  }

  Future<List<int>?> _createStoredImageBytes(File source) async {
    final sourceBytes = await source.readAsBytes();
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      return null;
    }

    final resized = _resizeToMaxSide(decoded, maxStoredImageSide);
    return img.encodeJpg(resized, quality: jpegQuality);
  }

  img.Image _resizeToMaxSide(img.Image image, int maxSide) {
    final longestSide = image.width > image.height ? image.width : image.height;
    if (longestSide <= maxSide) {
      return image;
    }

    if (image.width >= image.height) {
      return img.copyResize(image, width: maxSide);
    }

    return img.copyResize(image, height: maxSide);
  }
}
