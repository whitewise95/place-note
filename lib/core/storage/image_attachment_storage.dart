import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/ocr/mock_ocr_service.dart';

class ImageAttachmentStorage {
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

    final extension = p.extension(source.path).isEmpty
        ? '.jpg'
        : p.extension(source.path).toLowerCase();
    final filename =
        'capture-${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = File(p.join(imageDir.path, filename));
    await source.copy(destination.path);
    return destination.path;
  }
}
