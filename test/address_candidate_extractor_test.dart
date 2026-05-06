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
}
