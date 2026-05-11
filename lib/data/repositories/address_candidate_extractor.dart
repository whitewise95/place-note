import '../models/address_candidate.dart';

class AddressCandidateExtractor {
  static final RegExp _addressLinePattern = RegExp(
    r'((서울|서울특별시|부산|부산광역시|대구|대구광역시|인천|인천광역시|광주|광주광역시|대전|대전광역시|울산|울산광역시|세종|세종특별자치시|경기|경기도|강원|강원특별자치도|충북|충청북도|충남|충청남도|전북|전라북도|전남|전라남도|경북|경상북도|경남|경상남도|제주|제주특별자치도)[^\n]{0,55}?(대로|로|길)\s?\d{1,5}[^\n]{0,22})',
  );

  static final RegExp _hyundaiSeoulPattern = RegExp(
    r'(더\s?현대\s?서울|THE\s?HYUNDAI\s?SEOUL)',
    caseSensitive: false,
  );

  static final RegExp _venuePrefixPattern = RegExp(
    r'^(?:[^\w가-힣]{0,6})?(?:장소|위치|행사장|venue|location)\s*[:：.\-]?\s*(.+)$',
    caseSensitive: false,
  );

  static final RegExp _venueKeywordPattern = RegExp(
    r'(행사장|특별행사장|박람회장|컨벤션|웨딩홀|스토어\s?행사장)$',
  );

  static List<AddressCandidate> extract(String ocrText) {
    final searchableText = [
      ocrText,
      ocrText.replaceAll(RegExp(r'\s*\n\s*'), ' '),
    ].join('\n');

    final seen = <String>{};
    final candidates = <AddressCandidate>[];

    _addKnownPlaceCandidates(
      ocrText: ocrText,
      seen: seen,
      candidates: candidates,
    );

    final matches = _addressLinePattern.allMatches(searchableText).toList();
    for (final match in matches) {
      final raw = match.group(0)?.trim();
      if (raw == null || raw.isEmpty) {
        continue;
      }

      _addCandidate(
        candidates: candidates,
        seen: seen,
        rawText: raw,
        normalizedAddress: _normalize(raw),
        detailAddress: _extractDetail(raw),
        confidence: candidates.isEmpty ? 94 : 86,
      );
    }

    _addVenueLineCandidates(
      ocrText: ocrText,
      seen: seen,
      candidates: candidates,
    );

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

  static void _addKnownPlaceCandidates({
    required String ocrText,
    required Set<String> seen,
    required List<AddressCandidate> candidates,
  }) {
    if (!_hyundaiSeoulPattern.hasMatch(ocrText)) {
      return;
    }

    final raw = _bestLineContaining(ocrText, _hyundaiSeoulPattern) ?? '더현대 서울';
    _addCandidate(
      candidates: candidates,
      seen: seen,
      rawText: raw,
      normalizedAddress: '서울 영등포구 여의대로 108 더현대 서울',
      detailAddress: '더현대 서울',
      confidence: 92,
    );
  }

  static void _addVenueLineCandidates({
    required String ocrText,
    required Set<String> seen,
    required List<AddressCandidate> candidates,
  }) {
    for (final line in ocrText.split(RegExp(r'\r?\n'))) {
      final cleaned = _cleanOcrLine(line);
      if (cleaned.length < 4) {
        continue;
      }

      final venueText = _extractVenueText(cleaned);
      if (venueText == null || venueText.length < 4) {
        continue;
      }

      _addCandidate(
        candidates: candidates,
        seen: seen,
        rawText: cleaned,
        normalizedAddress: _normalize(venueText),
        detailAddress: '장소명 후보',
        confidence: candidates.isEmpty ? 84 : 76,
      );
    }
  }

  static void _addCandidate({
    required List<AddressCandidate> candidates,
    required Set<String> seen,
    required String rawText,
    required String normalizedAddress,
    required int confidence,
    String? detailAddress,
  }) {
    final normalized = _normalize(normalizedAddress);
    if (normalized.isEmpty || !seen.add(normalized)) {
      return;
    }

    candidates.add(
      AddressCandidate(
        id: 'candidate-${candidates.length + 1}',
        rawText: rawText.trim(),
        normalizedAddress: normalized,
        detailAddress: detailAddress,
        confidence: confidence,
      ),
    );
  }

  static String? _bestLineContaining(String ocrText, RegExp pattern) {
    for (final line in ocrText.split(RegExp(r'\r?\n'))) {
      final cleaned = _cleanOcrLine(line);
      if (pattern.hasMatch(cleaned)) {
        return cleaned;
      }
    }
    return null;
  }

  static String? _extractVenueText(String line) {
    final prefixed = _venuePrefixPattern.firstMatch(line)?.group(1);
    if (prefixed != null) {
      return _stripVenueNoise(prefixed);
    }

    if (_venueKeywordPattern.hasMatch(line) && line.length <= 40) {
      return _stripVenueNoise(line);
    }

    return null;
  }

  static String _cleanOcrLine(String line) {
    return line
        .replaceAll(RegExp(r'[✅✔💕💖💝➡️→※]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _stripVenueNoise(String text) {
    return text
        .replaceAll(RegExp(r'^(?:장소|위치|행사장)\s*[:：.\-]?\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[,.]$'), '')
        .trim();
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
