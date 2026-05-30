import 'package:address_research_mobile/app.dart';
import 'package:address_research_mobile/data/models/address_candidate.dart';
import 'package:address_research_mobile/data/models/extraction_result.dart';
import 'package:address_research_mobile/data/models/research_report.dart';
import 'package:address_research_mobile/data/models/text_folder.dart';
import 'package:address_research_mobile/data/ocr/mock_ocr_service.dart';
import 'package:address_research_mobile/data/repositories/address_analysis_repository.dart';
import 'package:address_research_mobile/features/capture/capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture flow returns saved report id to the launcher',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      RepositoryScope(
        repository: _FakeAddressAnalysisRepository(),
        child: const MaterialApp(home: _CaptureResultHarness()),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('이미지 선택'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('샘플 데이터로 시작'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('샘플 데이터로 시작'));
    await tester.pumpAndSettle();

    expect(find.text('result:report-1'), findsOneWidget);
  });
}

class _CaptureResultHarness extends StatefulWidget {
  const _CaptureResultHarness();

  @override
  State<_CaptureResultHarness> createState() => _CaptureResultHarnessState();
}

class _CaptureResultHarnessState extends State<_CaptureResultHarness> {
  String result = 'waiting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final reportId = await Navigator.of(context).push<String>(
                MaterialPageRoute<String>(
                  builder: (_) =>
                      const CaptureScreen(returnToWebAfterSave: true),
                ),
              );
              setState(() => result = reportId ?? 'none');
            },
            child: const Text('open'),
          ),
          Text('result:$result'),
        ],
      ),
    );
  }
}

class _FakeAddressAnalysisRepository implements AddressAnalysisRepository {
  @override
  Future<ExtractionResult> extractCandidates(String? imagePath) async {
    return const ExtractionResult(
      imagePath: MockOcrSource.sample,
      ocrText: '연희숲속쉼터\n서대문구 연희동 산5-79',
      candidates: [
        AddressCandidate(
          id: 'candidate-1',
          rawText: '연희숲속쉼터',
          normalizedAddress: '연희숲속쉼터',
          confidence: 95,
        ),
      ],
    );
  }

  @override
  Future<AddressCandidate> resolveAddress(AddressCandidate candidate) async {
    return AddressCandidate(
      id: candidate.id,
      rawText: candidate.rawText,
      normalizedAddress: '서울 서대문구 연희동 산5-79',
      confidence: 95,
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
      createdAt: DateTime(2026, 5, 31),
      folderId: folderId,
      imagePath: imagePath,
      ocrText: ocrText,
      detailAddress: candidate.detailAddress,
      latitude: candidate.latitude,
      longitude: candidate.longitude,
    );
  }

  @override
  Future<void> save(ResearchReport result) async {}

  @override
  Future<TextFolder> createFolder(String name) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<void> deleteFolder(String id) => throw UnimplementedError();

  @override
  Future<List<TextFolder>> findFolders() => throw UnimplementedError();

  @override
  Future<List<ResearchReport>> findHistories() => throw UnimplementedError();

  @override
  Future<void> renameFolder(TextFolder folder, String name) =>
      throw UnimplementedError();
}
