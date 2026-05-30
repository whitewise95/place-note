import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/address_candidate.dart';

class KakaoAddressSearchService {
  KakaoAddressSearchService({
    http.Client? client,
    String apiKey = const String.fromEnvironment('KAKAO_REST_API_KEY'),
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey.trim();

  final http.Client _client;
  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<AddressCandidate?> resolve(AddressCandidate candidate) async {
    final query = candidate.normalizedAddress.trim().isEmpty
        ? candidate.rawText.trim()
        : candidate.normalizedAddress.trim();

    if (!isConfigured || query.isEmpty) {
      return null;
    }

    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/address.json',
      {'query': query},
    );
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final documents = decoded['documents'];
    if (documents is! List || documents.isEmpty) {
      return null;
    }

    final first = documents.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }

    final roadAddress = _nestedAddressName(first['road_address']);
    final lotAddress = _nestedAddressName(first['address']);
    final locationAddress = first['address'] is Map<String, dynamic>
        ? first['address'] as Map<String, dynamic>
        : first['road_address'] as Map<String, dynamic>?;
    final documentAddress = first['address_name'] as String?;
    final normalizedAddress = roadAddress ?? documentAddress ?? lotAddress;

    if (normalizedAddress == null || normalizedAddress.trim().isEmpty) {
      return null;
    }

    return AddressCandidate(
      id: candidate.id,
      rawText: candidate.rawText,
      normalizedAddress: normalizedAddress.trim(),
      confidence: 96,
      detailAddress: _detailAddress(
        roadAddress: roadAddress,
        lotAddress: lotAddress,
        fallback: candidate.detailAddress,
      ),
      latitude: _coordinate(first['y']),
      longitude: _coordinate(first['x']),
      province: _nestedText(locationAddress, 'region_1depth_name'),
      district: _nestedText(locationAddress, 'region_2depth_name'),
      locality: _nestedText(locationAddress, 'region_3depth_name'),
    );
  }

  double? _coordinate(Object? value) {
    return value is String ? double.tryParse(value) : null;
  }

  String? _nestedText(Map<String, dynamic>? value, String key) {
    final text = value?[key];
    if (text is! String || text.trim().isEmpty) {
      return null;
    }
    return text.trim();
  }

  String? _nestedAddressName(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final addressName = value['address_name'];
    if (addressName is! String || addressName.trim().isEmpty) {
      return null;
    }

    return addressName.trim();
  }

  String? _detailAddress({
    required String? roadAddress,
    required String? lotAddress,
    required String? fallback,
  }) {
    final parts = <String>[
      if (fallback != null && fallback.trim().isNotEmpty) fallback.trim(),
      if (lotAddress != null && lotAddress != roadAddress) '지번: $lotAddress',
    ];

    if (parts.isNotEmpty) {
      return parts.join(' · ');
    }

    return null;
  }
}
