import 'package:address_research_mobile/data/models/address_candidate.dart';
import 'package:address_research_mobile/data/models/extraction_result.dart';
import 'package:address_research_mobile/data/models/research_report.dart';
import 'package:address_research_mobile/data/models/text_folder.dart';
import 'package:address_research_mobile/data/repositories/address_analysis_repository.dart';
import 'package:address_research_mobile/features/address/address_save_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves selected text and saves report before returning it', () async {
    final repository = _FakeAddressAnalysisRepository();
    const candidate = AddressCandidate(
      id: 'candidate-1',
      rawText: '연희숲속쉼터',
      normalizedAddress: '연희숲속쉼터',
      confidence: 80,
    );

    final report = await createAndSaveSelectedTextReport(
      repository: repository,
      candidate: candidate,
      imagePath: '/local/capture.jpg',
      ocrText: '연희숲속쉼터\n서대문구 연희동 산5-79',
      folderId: TextFolder.inboxId,
    );

    expect(repository.resolvedCandidate?.rawText, '연희숲속쉼터');
    expect(repository.createdCandidate?.normalizedAddress, '서울 서대문구 연희동 산5-79');
    expect(repository.savedReport?.id, 'report-1');
    expect(report.isSaved, isTrue);
    expect(report.latitude, 37.5742);
    expect(report.longitude, 126.9301);
  });
}

class _FakeAddressAnalysisRepository implements AddressAnalysisRepository {
  AddressCandidate? resolvedCandidate;
  AddressCandidate? createdCandidate;
  ResearchReport? savedReport;

  @override
  Future<AddressCandidate> resolveAddress(AddressCandidate candidate) async {
    resolvedCandidate = candidate;
    return AddressCandidate(
      id: candidate.id,
      rawText: candidate.rawText,
      normalizedAddress: '서울 서대문구 연희동 산5-79',
      confidence: 90,
      detailAddress: '연희숲속쉼터',
      latitude: 37.5742,
      longitude: 126.9301,
      province: '서울',
      district: '서대문구',
      locality: '연희동',
    );
  }

  @override
  Future<ResearchReport> createReport({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
    required String folderId,
  }) async {
    createdCandidate = candidate;
    return ResearchReport(
      id: 'report-1',
      rawAddress: candidate.rawText,
      normalizedAddress: candidate.normalizedAddress,
      summaryCards: const [],
      status: 'local',
      createdAt: DateTime(2026, 5, 30, 10),
      folderId: folderId,
      imagePath: imagePath,
      ocrText: ocrText,
      detailAddress: candidate.detailAddress,
      latitude: candidate.latitude,
      longitude: candidate.longitude,
      province: candidate.province,
      district: candidate.district,
      locality: candidate.locality,
    );
  }

  @override
  Future<void> save(ResearchReport result) async {
    savedReport = result;
  }

  @override
  Future<TextFolder> createFolder(String name) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<void> deleteFolder(String id) => throw UnimplementedError();

  @override
  Future<ExtractionResult> extractCandidates(String? imagePath) =>
      throw UnimplementedError();

  @override
  Future<List<TextFolder>> findFolders() => throw UnimplementedError();

  @override
  Future<List<ResearchReport>> findHistories() => throw UnimplementedError();

  @override
  Future<void> renameFolder(TextFolder folder, String name) =>
      throw UnimplementedError();
}
