import 'package:address_research_mobile/data/regions/address_region_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Seoul road address into province district and road', () {
    final region = AddressRegionParser.parse('서울 중구 퇴계로 409');

    expect(region.province, '서울');
    expect(region.district, '중구');
    expect(region.locality, '퇴계로');
  });

  test('parses nested city and district lot address', () {
    final region = AddressRegionParser.parse('경기 성남시 분당구 삼평동 629');

    expect(region.province, '경기');
    expect(region.district, '성남시 분당구');
    expect(region.locality, '삼평동');
  });

  test('parses town and village addresses', () {
    final region = AddressRegionParser.parse('제주 제주시 애월읍 하귀리 123-4');

    expect(region.province, '제주');
    expect(region.district, '제주시');
    expect(region.locality, '애월읍 하귀리');
  });

  test('normalizes long province names', () {
    final region = AddressRegionParser.parse('서울특별시 서대문구 연희동 산5-79');

    expect(region.province, '서울');
    expect(region.district, '서대문구');
    expect(region.locality, '연희동');
  });
}
