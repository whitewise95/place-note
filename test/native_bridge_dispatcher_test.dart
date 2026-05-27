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
