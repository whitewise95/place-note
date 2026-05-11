import '../../core/storage/report_storage.dart';
import '../mock/mock_report_factory.dart';
import '../models/address_candidate.dart';
import '../models/extraction_result.dart';
import '../models/research_report.dart';
import '../models/text_folder.dart';
import '../ocr/mlkit_ocr_service.dart';
import '../ocr/ocr_service.dart';
import 'address_analysis_repository.dart';
import 'address_candidate_extractor.dart';

class LocalAddressAnalysisRepository implements AddressAnalysisRepository {
  LocalAddressAnalysisRepository({
    OcrService? ocrService,
    ReportStorage? storage,
  })  : _ocrService = ocrService ?? MlKitOcrService(),
        _storage = storage ?? ReportStorage();

  final OcrService _ocrService;
  final ReportStorage _storage;

  @override
  Future<ExtractionResult> extractCandidates(String? imagePath) async {
    // TODO(server): 서버 OCR 도입 시 POST /v1/address-analyses 로 교체한다.
    final ocrText = await _ocrService.recognize(imagePath);
    final candidates = AddressCandidateExtractor.extract(ocrText);

    return ExtractionResult(
      imagePath: imagePath,
      ocrText: ocrText,
      candidates: candidates,
    );
  }

  @override
  Future<ResearchReport> createReport({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
    required String folderId,
  }) async {
    // TODO(server): Spring Boot API 연동 시 POST /v1/address/reports 또는 GET /v1/address/reports 호출로 교체한다.
    return MockReportFactory.fromCandidate(
      candidate: candidate,
      imagePath: imagePath,
      ocrText: ocrText,
      folderId: folderId,
    );
  }

  @override
  Future<List<ResearchReport>> findHistories() {
    // TODO(server): 서버 이력 동기화 시 GET /v1/address-analyses 로 교체한다.
    return _storage.loadReports();
  }

  @override
  Future<List<TextFolder>> findFolders() {
    return _storage.loadFolders();
  }

  @override
  Future<TextFolder> createFolder(String name) async {
    final folder = TextFolder(
      id: 'folder-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _storage.saveFolder(folder);
    return folder;
  }

  @override
  Future<void> renameFolder(TextFolder folder, String name) {
    return _storage.saveFolder(folder.copyWith(name: name.trim()));
  }

  @override
  Future<void> deleteFolder(String id) {
    return _storage.deleteFolder(id);
  }

  @override
  Future<void> save(ResearchReport result) {
    // TODO(server): 서버 저장 도입 시 POST /v1/address-analyses 결과와 로컬 캐시를 함께 저장한다.
    return _storage.saveReport(result);
  }

  @override
  Future<void> delete(String id) {
    // TODO(server): 서버 이력 삭제 도입 시 DELETE /v1/address-analyses/{id} 호출을 추가한다.
    return _storage.deleteReport(id);
  }
}
