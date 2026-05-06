import '../../core/storage/report_storage.dart';
import '../mock/mock_ocr_service.dart';
import '../mock/mock_report_factory.dart';
import '../models/address_candidate.dart';
import '../models/extraction_result.dart';
import '../models/research_report.dart';
import 'address_analysis_repository.dart';
import 'address_candidate_extractor.dart';

class LocalAddressAnalysisRepository implements AddressAnalysisRepository {
  LocalAddressAnalysisRepository({
    MockOcrService? ocrService,
    ReportStorage? storage,
  })  : _ocrService = ocrService ?? MockOcrService(),
        _storage = storage ?? ReportStorage();

  final MockOcrService _ocrService;
  final ReportStorage _storage;

  @override
  Future<ExtractionResult> extractCandidates(String? imagePath) async {
    // TODO(server): Spring Boot API 연동 시 POST /v1/address-analyses 로 교체한다.
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
  }) async {
    // TODO(server): Spring Boot API 연동 시 POST /v1/address/reports 또는 GET /v1/address/reports 호출로 교체한다.
    return MockReportFactory.fromCandidate(
      candidate: candidate,
      imagePath: imagePath,
      ocrText: ocrText,
    );
  }

  @override
  Future<List<ResearchReport>> findHistories() {
    // TODO(server): 서버 이력 동기화 시 GET /v1/address-analyses 로 교체한다.
    return _storage.loadReports();
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
