import '../models/address_candidate.dart';
import '../models/research_report.dart';

class MockReportFactory {
  static ResearchReport fromCandidate({
    required AddressCandidate candidate,
    required String? imagePath,
    required String ocrText,
    required String folderId,
  }) {
    final now = DateTime.now();

    return ResearchReport(
      id: 'report-${now.microsecondsSinceEpoch}',
      rawAddress: candidate.rawText,
      normalizedAddress: candidate.normalizedAddress,
      folderId: folderId,
      detailAddress: candidate.detailAddress,
      latitude: candidate.latitude,
      longitude: candidate.longitude,
      province: candidate.province,
      district: candidate.district,
      locality: candidate.locality,
      imagePath: imagePath,
      ocrText: ocrText,
      status: 'local_mock',
      createdAt: now,
      summaryCards: const [
        SummaryCard(
          title: '선택한 텍스트',
          value: '저장 준비 완료',
          description: 'OCR 원문에서 사용자가 고른 문장을 로컬 폴더에 저장합니다.',
          status: 'mock',
        ),
        SummaryCard(
          title: 'OCR 원문',
          value: '보관됨',
          description: '나중에 다시 볼 수 있도록 이미지 OCR 전체 텍스트도 함께 보관합니다.',
          status: 'mock',
        ),
        SummaryCard(
          title: '자동 분류',
          value: 'TODO',
          description: '서버 연동 후 장소, URL, 전화번호 같은 엔티티를 자동 분류합니다.',
          status: 'server_todo',
        ),
      ],
    );
  }
}
