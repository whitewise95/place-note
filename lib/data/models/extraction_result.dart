import 'address_candidate.dart';

class ExtractionResult {
  const ExtractionResult({
    required this.imagePath,
    required this.ocrText,
    required this.candidates,
  });

  final String? imagePath;
  final String ocrText;
  final List<AddressCandidate> candidates;
}
