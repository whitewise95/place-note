import '../models/address_candidate.dart';
import '../models/research_report.dart';

class MockReportFactory {
  static ResearchReport fromCandidate({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
  }) {
    final now = DateTime.now();

    return ResearchReport(
      id: 'report-${now.microsecondsSinceEpoch}',
      rawAddress: candidate.rawText,
      normalizedAddress: candidate.normalizedAddress,
      detailAddress: candidate.detailAddress,
      imagePath: imagePath,
      ocrText: ocrText,
      status: 'local_mock',
      createdAt: now,
      summaryCards: const [
        SummaryCard(
          title: '정규화 주소',
          value: '추정 완료',
          description: '도로명주소 검증 전 Mock 정규화 결과입니다.',
          status: 'mock',
        ),
        SummaryCard(
          title: '건축물 정보',
          value: 'TODO',
          description: '건축물대장 API 연결 후 용도, 면적, 층수 정보를 표시합니다.',
          status: 'server_todo',
        ),
        SummaryCard(
          title: '토지이용 계획',
          value: 'TODO',
          description: '토지이음 또는 내부 수집 API 연결 후 표시합니다.',
          status: 'server_todo',
        ),
        SummaryCard(
          title: '실거래가',
          value: 'TODO',
          description: '국토교통부 실거래가 자료 연동 후 최근 거래를 표시합니다.',
          status: 'server_todo',
        ),
        SummaryCard(
          title: '주변 시설',
          value: 'TODO',
          description: '지도/좌표 변환 이후 역, 학교, 편의시설 정보를 표시합니다.',
          status: 'server_todo',
        ),
      ],
    );
  }
}
