import 'package:flutter_test/flutter_test.dart';
import 'package:address_research_mobile/data/repositories/address_candidate_extractor.dart';

void main() {
  test('extracts Korean road address candidates from mock OCR text', () {
    final candidates = AddressCandidateExtractor.extract('''
부동산 매물 캡쳐
서울시 강남구 테헤란로 123 301호
참고 주소: 서울 강남구 테헤란로 123
''');

    expect(candidates, isNotEmpty);
    expect(candidates.first.normalizedAddress, contains('서울 강남구 테헤란로 123'));
    expect(candidates.first.detailAddress, '301호');
  });

  test('promotes known venue names to address candidates', () {
    final candidates = AddressCandidateExtractor.extract('''
대형웨딩박람회
장소 : 여의도 더현대 서울 특별행사장
무료신청 : www.sswfair.com
''');

    expect(candidates, isNotEmpty);
    expect(candidates.first.normalizedAddress, '서울 영등포구 여의대로 108 더현대 서울');
    expect(candidates.first.detailAddress, '더현대 서울');
  });

  test('extracts venue lines when no road address exists', () {
    final candidates = AddressCandidateExtractor.extract('''
일정 : 4월4일(토)~5일(일)
장소 : 부산 벡스코 특별행사장
신청 : example.com
''');

    expect(candidates, isNotEmpty);
    expect(candidates.first.normalizedAddress, '부산 벡스코 특별행사장');
    expect(candidates.first.detailAddress, '장소명 후보');
  });
}
