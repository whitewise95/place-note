import 'dart:convert';

import 'package:address_research_mobile/data/kakao/kakao_address_search_service.dart';
import 'package:address_research_mobile/data/models/address_candidate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('resolves selected text to Kakao road address first', () async {
    final service = KakaoAddressSearchService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.url.host, 'dapi.kakao.com');
        expect(request.url.path, '/v2/local/search/address.json');
        expect(request.url.queryParameters['query'], '서울 중구 퇴계로 409-9 1층');
        expect(request.headers['Authorization'], 'KakaoAK test-key');

        return http.Response.bytes(
          utf8.encode(
            '''
          {
            "documents": [
              {
                "address_name": "서울 중구 흥인동 13-1",
                "address": {
                  "address_name": "서울 중구 흥인동 13-1"
                },
                "road_address": {
                  "address_name": "서울 중구 퇴계로 409"
                }
              }
            ]
          }
          ''',
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final resolved = await service.resolve(
      const AddressCandidate(
        id: 'candidate-1',
        rawText: '서울 중구 퇴계로 409-9 1층',
        normalizedAddress: '서울 중구 퇴계로 409-9 1층',
        confidence: 80,
        detailAddress: '1층',
      ),
    );

    expect(resolved, isNotNull);
    expect(resolved!.normalizedAddress, '서울 중구 퇴계로 409');
    expect(resolved.rawText, '서울 중구 퇴계로 409-9 1층');
    expect(resolved.detailAddress, '1층 · 지번: 서울 중구 흥인동 13-1');
    expect(resolved.confidence, 96);
  });

  test('returns null without API key', () async {
    var called = false;
    final service = KakaoAddressSearchService(
      apiKey: '',
      client: MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    final resolved = await service.resolve(
      const AddressCandidate(
        id: 'candidate-1',
        rawText: '서울 중구 퇴계로 409',
        normalizedAddress: '서울 중구 퇴계로 409',
        confidence: 80,
      ),
    );

    expect(resolved, isNull);
    expect(called, isFalse);
  });
}
