import 'package:address_research_mobile/app.dart';
import 'package:address_research_mobile/data/models/address_candidate.dart';
import 'package:address_research_mobile/data/models/extraction_result.dart';
import 'package:address_research_mobile/data/models/research_report.dart';
import 'package:address_research_mobile/data/models/text_folder.dart';
import 'package:address_research_mobile/data/repositories/address_analysis_repository.dart';
import 'package:address_research_mobile/features/address/address_candidate_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('web capture save flow pops back after saving', (tester) async {
    final repository = _FakeAddressAnalysisRepository();

    await tester.pumpWidget(
      RepositoryScope(
        repository: repository,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const AddressCandidateScreen(
                        result: ExtractionResult(
                          imagePath: null,
                          ocrText: '연희숲속쉼터',
                          candidates: [],
                        ),
                        returnToWebAfterSave: true,
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '연희숲속쉼터');
    await tester.tap(find.text('폴더에 저장하기'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.text('텍스트 저장'), findsNothing);
    expect(repository.savedReport?.normalizedAddress, '서울 서대문구 연희동 산5-79');
  });
}

class _FakeAddressAnalysisRepository implements AddressAnalysisRepository {
  ResearchReport? savedReport;

  @override
  Future<List<TextFolder>> findFolders() async => [TextFolder.inbox()];

  @override
  Future<AddressCandidate> resolveAddress(AddressCandidate candidate) async {
    return AddressCandidate(
      id: candidate.id,
      rawText: candidate.rawText,
      normalizedAddress: '서울 서대문구 연희동 산5-79',
      confidence: 90,
      detailAddress: '연희숲속쉼터',
      latitude: 37.5742,
      longitude: 126.9301,
    );
  }

  @override
  Future<ResearchReport> createReport({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
    required String folderId,
  }) async {
    return ResearchReport(
      id: 'report-1',
      rawAddress: candidate.rawText,
      normalizedAddress: candidate.normalizedAddress,
      summaryCards: const [],
      status: 'local',
      createdAt: DateTime(2026, 5, 30, 16),
      folderId: folderId,
      imagePath: imagePath,
      ocrText: ocrText,
      detailAddress: candidate.detailAddress,
      latitude: candidate.latitude,
      longitude: candidate.longitude,
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
  Future<List<ResearchReport>> findHistories() => throw UnimplementedError();

  @override
  Future<void> renameFolder(TextFolder folder, String name) =>
      throw UnimplementedError();
}
