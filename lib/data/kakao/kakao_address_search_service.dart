import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/address_candidate.dart';
import '../regions/address_region_parser.dart';

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

    final addressCandidate = await _resolveAddressQuery(candidate, query);
    if (addressCandidate != null) {
      return addressCandidate;
    }

    return _resolveKeywordQuery(candidate, query);
  }

  Future<AddressCandidate?> _resolveAddressQuery(
    AddressCandidate candidate,
    String query,
  ) async {
    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/address.json',
      {'query': query},
    );
    final decoded = await _getJson(uri);
    if (decoded == null) return null;

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
    final address = _asStringMap(first['address']);
    final road = _asStringMap(first['road_address']);
    final locationAddress = address ?? road;
    final documentAddress = _documentText(first, 'address_name');
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

  Future<AddressCandidate?> _resolveKeywordQuery(
    AddressCandidate candidate,
    String query,
  ) async {
    final uri = Uri.https(
      'dapi.kakao.com',
      '/v2/local/search/keyword.json',
      {'query': query},
    );
    final decoded = await _getJson(uri);
    if (decoded == null) return null;

    final documents = decoded['documents'];
    if (documents is! List || documents.isEmpty) {
      return null;
    }

    final first = documents.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }

    final roadAddress = _documentText(first, 'road_address_name');
    final lotAddress = _documentText(first, 'address_name');
    final placeName = _documentText(first, 'place_name');
    final normalizedAddress = roadAddress ?? lotAddress ?? placeName;

    if (normalizedAddress == null || normalizedAddress.trim().isEmpty) {
      return null;
    }

    final region = AddressRegionParser.parse(normalizedAddress);

    return AddressCandidate(
      id: candidate.id,
      rawText: candidate.rawText,
      normalizedAddress: normalizedAddress.trim(),
      confidence: 90,
      detailAddress: _keywordDetailAddress(
        placeName: placeName,
        fallback: candidate.detailAddress,
      ),
      latitude: _coordinate(first['y']),
      longitude: _coordinate(first['x']),
      province: region.province,
      district: region.district,
      locality: region.locality,
    );
  }

  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_apiKey'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
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

  Map<String, dynamic>? _asStringMap(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  String? _documentText(Map<String, dynamic> value, String key) {
    final text = value[key];
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

  String? _keywordDetailAddress({
    required String? placeName,
    required String? fallback,
  }) {
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }

    if (placeName != null && placeName.trim().isNotEmpty) {
      return placeName.trim();
    }

    return null;
  }
}
