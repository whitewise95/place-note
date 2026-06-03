import 'package:address_research_mobile/bridge/native_bridge_dispatcher.dart';
import 'package:address_research_mobile/data/models/research_report.dart';
import 'package:address_research_mobile/data/models/text_folder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches folders.list as a successful response envelope', () async {
    final dispatcher = NativeBridgeDispatcher(
      loadFolders: () async => [TextFolder.inbox()],
      loadReports: () async => const [],
      loadImageDataUrl: (_) async => null,
    );

    final response = await dispatcher.handle(
      '{"id":"1","method":"folders.list","params":{}}',
    );

    expect(response['id'], '1');
    expect(response['ok'], true);
    expect((response['result'] as List).first['name'], '기본 보관함');
  });

  test('dispatches reports.list with map data and display image', () async {
    final dispatcher = NativeBridgeDispatcher(
      loadFolders: () async => [TextFolder.inbox()],
      loadReports: () async => [
        ResearchReport(
          id: 'report-1',
          rawAddress: '퇴계로',
          normalizedAddress: '서울 중구 퇴계로 409',
          summaryCards: const [],
          status: 'local',
          createdAt: DateTime(2026, 5, 25, 21, 49),
          imagePath: '/managed/capture.jpg',
          latitude: 37.565,
          longitude: 127.009,
        ),
      ],
      loadImageDataUrl: (_) async => 'data:image/jpeg;base64,aW1hZ2U=',
    );

    final response = await dispatcher.handle(
      '{"id":"2","method":"reports.list","params":{}}',
    );
    final report = (response['result'] as List).single as Map<String, dynamic>;

    expect(report['normalizedAddress'], '서울 중구 퇴계로 409');
    expect(report['latitude'], 37.565);
    expect(report['longitude'], 127.009);
    expect(report['imageDataUrl'], 'data:image/jpeg;base64,aW1hZ2U=');
  });

  test('dispatches reports.save with selected text and Kakao metadata',
      () async {
    ResearchReport? savedReport;
    final dispatcher = NativeBridgeDispatcher(
      loadFolders: () async => [TextFolder.inbox()],
      loadReports: () async => savedReport == null ? [] : [savedReport!],
      loadImageDataUrl: (_) async => 'data:image/jpeg;base64,aW1hZ2U=',
      saveReportFromWeb: ({
        required folderId,
        required selectedText,
        required normalizedAddress,
        required imagePath,
        required ocrText,
        detailAddress,
        latitude,
        longitude,
        province,
        district,
        locality,
      }) async {
        savedReport = ResearchReport(
          id: 'report-saved',
          rawAddress: selectedText,
          normalizedAddress: normalizedAddress,
          summaryCards: const [],
          status: 'local_web',
          createdAt: DateTime(2026, 6, 3, 10),
          folderId: folderId,
          imagePath: imagePath,
          ocrText: ocrText,
          detailAddress: detailAddress,
          latitude: latitude,
          longitude: longitude,
          province: province,
          district: district,
          locality: locality,
        );
        return savedReport!;
      },
    );

    final response = await dispatcher.handle(
      '{"id":"4","method":"reports.save","params":{'
      '"folderId":"folder-inbox",'
      '"selectedText":"연희숲속쉼터",'
      '"normalizedAddress":"서울 서대문구 연희동 산5-79",'
      '"detailAddress":"연희숲속쉼터",'
      '"latitude":37.5742,'
      '"longitude":126.9301,'
      '"province":"서울",'
      '"district":"서대문구",'
      '"locality":"연희동",'
      '"imagePath":"/tmp/capture.jpg",'
      '"ocrText":"연희숲속쉼터\\n서대문구 연희동 산5-79"'
      '}}',
    );
    final report = response['result'] as Map<String, dynamic>;

    expect(response['ok'], true);
    expect(report['id'], 'report-saved');
    expect(report['folderId'], TextFolder.inboxId);
    expect(report['normalizedAddress'], '서울 서대문구 연희동 산5-79');
    expect(report['rawAddress'], '연희숲속쉼터');
    expect(report['latitude'], 37.5742);
    expect(report['longitude'], 126.9301);
    expect(report['imageDataUrl'], 'data:image/jpeg;base64,aW1hZ2U=');
  });

  test('returns structured errors for unsupported and malformed messages',
      () async {
    final dispatcher = NativeBridgeDispatcher(
      loadFolders: () async => const [],
      loadReports: () async => const [],
      loadImageDataUrl: (_) async => null,
    );

    final unsupported =
        await dispatcher.handle('{"id":"3","method":"reports.delete"}');
    final malformed = await dispatcher.handle('not json');

    expect(unsupported['ok'], false);
    expect(unsupported['error'], 'unsupported_method');
    expect(malformed['ok'], false);
    expect(malformed['error'], 'invalid_request');
  });
}
