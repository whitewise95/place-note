import '../models/address_candidate.dart';
import '../models/extraction_result.dart';
import '../models/research_report.dart';
import '../models/text_folder.dart';

abstract class AddressAnalysisRepository {
  Future<ExtractionResult> extractCandidates(String? imagePath);

  Future<ResearchReport> createReport({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
    required String folderId,
  });

  Future<AddressCandidate> resolveAddress(AddressCandidate candidate);

  Future<List<ResearchReport>> findHistories();

  Future<List<TextFolder>> findFolders();

  Future<TextFolder> createFolder(String name);

  Future<void> renameFolder(TextFolder folder, String name);

  Future<void> deleteFolder(String id);

  Future<void> save(ResearchReport result);

  Future<void> delete(String id);
}
