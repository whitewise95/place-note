import '../models/address_candidate.dart';

class AddressCandidateExtractor {
  static final RegExp _addressLinePattern = RegExp(
    r'((서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주)[^\n]{0,45}?(로|길|대로)\s?\d{1,5}[^\n]{0,18})',
  );

  static List<AddressCandidate> extract(String ocrText) {
    final matches = _addressLinePattern.allMatches(ocrText).toList();
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
        .replaceAll('서울시', '서울')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[,.]$'), '')
        .trim();
  }

  static String? _extractDetail(String raw) {
    final detail = RegExp(r'(\d{1,4}\s?호)').firstMatch(raw)?.group(0);
    return detail?.replaceAll(' ', '');
  }
}
