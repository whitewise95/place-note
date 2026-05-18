import 'address_region.dart';

class AddressRegionParser {
  static const Map<String, String> _provinceAliases = {
    '서울': '서울',
    '서울시': '서울',
    '서울특별시': '서울',
    '부산': '부산',
    '부산광역시': '부산',
    '대구': '대구',
    '대구광역시': '대구',
    '인천': '인천',
    '인천광역시': '인천',
    '광주': '광주',
    '광주광역시': '광주',
    '대전': '대전',
    '대전광역시': '대전',
    '울산': '울산',
    '울산광역시': '울산',
    '세종': '세종',
    '세종특별자치시': '세종',
    '경기': '경기',
    '경기도': '경기',
    '강원': '강원',
    '강원특별자치도': '강원',
    '충북': '충북',
    '충청북도': '충북',
    '충남': '충남',
    '충청남도': '충남',
    '전북': '전북',
    '전라북도': '전북',
    '전남': '전남',
    '전라남도': '전남',
    '경북': '경북',
    '경상북도': '경북',
    '경남': '경남',
    '경상남도': '경남',
    '제주': '제주',
    '제주특별자치도': '제주',
  };

  static AddressRegion parse(String value) {
    final tokens = value
        .replaceAll(RegExp(r'[,()]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const AddressRegion();
    }

    final province = _provinceAliases[tokens.first];
    final startIndex = province == null ? 0 : 1;
    final districtParts = <String>[];
    var index = startIndex;

    while (index < tokens.length && _isDistrictToken(tokens[index])) {
      districtParts.add(tokens[index]);
      index += 1;
    }

    final localityParts = <String>[];
    while (index < tokens.length && _isLocalityToken(tokens[index])) {
      localityParts.add(tokens[index]);
      index += 1;
    }

    if (localityParts.isEmpty && index < tokens.length) {
      final road = _roadName(tokens[index]);
      if (road != null) {
        localityParts.add(road);
      }
    }

    return AddressRegion(
      province: province,
      district: districtParts.isEmpty ? null : districtParts.join(' '),
      locality: localityParts.isEmpty ? null : localityParts.join(' '),
    );
  }

  static bool _isDistrictToken(String token) {
    return RegExp(r'.+(시|군|구)$').hasMatch(token);
  }

  static bool _isLocalityToken(String token) {
    return RegExp(r'.+(읍|면|동|리)$').hasMatch(token);
  }

  static String? _roadName(String token) {
    final match = RegExp(r'^(.+(?:대로|로|길))\d*$').firstMatch(token);
    return match?.group(1);
  }
}
