import 'package:address_research_mobile/data/models/research_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves Kakao map metadata when a saved report is serialized', () {
    final report = ResearchReport(
      id: 'report-1',
      rawAddress: '서울 중구 퇴계로 409',
      normalizedAddress: '서울 중구 퇴계로 409',
      summaryCards: const [],
      status: 'local',
      createdAt: DateTime(2026, 5, 25),
      latitude: 37.565,
      longitude: 127.009,
      province: '서울',
      district: '중구',
      locality: '흥인동',
    );

    final restored = ResearchReport.fromJson(report.toJson());

    expect(restored.latitude, 37.565);
    expect(restored.longitude, 127.009);
    expect(restored.province, '서울');
    expect(restored.district, '중구');
    expect(restored.locality, '흥인동');
  });
}
