import '../models/address_candidate.dart';
import '../models/extraction_result.dart';
import '../models/research_report.dart';

abstract class AddressAnalysisRepository {
  Future<ExtractionResult> extractCandidates(String? imagePath);

  Future<ResearchReport> createReport({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
  });

  Future<List<ResearchReport>> findHistories();

  Future<void> save(ResearchReport result);

  Future<void> delete(String id);
}
