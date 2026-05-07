import '../models/address_candidate.dart';

class AddressCandidateExtractor {
  static final RegExp _addressLinePattern = RegExp(
    r'((서울|서울특별시|부산|부산광역시|대구|대구광역시|인천|인천광역시|광주|광주광역시|대전|대전광역시|울산|울산광역시|세종|세종특별자치시|경기|경기도|강원|강원특별자치도|충북|충청북도|충남|충청남도|전북|전라북도|전남|전라남도|경북|경상북도|경남|경상남도|제주|제주특별자치도)[^\n]{0,55}?(대로|로|길)\s?\d{1,5}[^\n]{0,22})',
  );

  static List<AddressCandidate> extract(String ocrText) {
    final searchableText = [
      ocrText,
      ocrText.replaceAll(RegExp(r'\s*\n\s*'), ' '),
    ].join('\n');

    final matches = _addressLinePattern.allMatches(searchableText).toList();
    final seen = <String>{};
    final candidates = <AddressCandidate>[];

    for (final match in matches) {
      final raw = match.group(0)?.trim();
      if (raw == null || raw.isEmpty) {
        continue;
      }

      final normalized = _normalize(raw);
      if (!seen.add(normalized)) {
        continue;
      }

      candidates.add(
        AddressCandidate(
          id: 'candidate-${candidates.length + 1}',
          rawText: raw,
          normalizedAddress: normalized,
          detailAddress: _extractDetail(raw),
          confidence: candidates.isEmpty ? 94 : 86,
        ),
      );
    }

    return candidates;
  }

  static AddressCandidate fromManualInput(String address) {
    final normalized = _normalize(address);
    return AddressCandidate(
      id: 'candidate-manual-${DateTime.now().microsecondsSinceEpoch}',
      rawText: address.trim(),
      normalizedAddress: normalized,
      detailAddress: _extractDetail(address),
      confidence: 80,
    );
  }

  static String _normalize(String raw) {
    return raw
        .replaceAll('서울특별시', '서울')
        .replaceAll('서울시', '서울')
        .replaceAll('부산광역시', '부산')
        .replaceAll('대구광역시', '대구')
        .replaceAll('인천광역시', '인천')
        .replaceAll('광주광역시', '광주')
        .replaceAll('대전광역시', '대전')
        .replaceAll('울산광역시', '울산')
        .replaceAll('세종특별자치시', '세종')
        .replaceAll('경기도', '경기')
        .replaceAll('강원특별자치도', '강원')
        .replaceAll('충청북도', '충북')
        .replaceAll('충청남도', '충남')
        .replaceAll('전라북도', '전북')
        .replaceAll('전라남도', '전남')
        .replaceAll('경상북도', '경북')
        .replaceAll('경상남도', '경남')
        .replaceAll('제주특별자치도', '제주')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[,.]$'), '')
        .trim();
  }

  static String? _extractDetail(String raw) {
    final detail = RegExp(r'(\d{1,4}\s?호)').firstMatch(raw)?.group(0);
    return detail?.replaceAll(' ', '');
  }
}
