class MockOcrService {
  Future<String> recognize(String? imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (imagePath == null || imagePath == MockOcrSource.sample) {
      return sampleText;
    }

    // TODO(server): 실제 OCR 도입 시 ML Kit 또는 POST /v1/address-analyses 호출로 교체한다.
    return sampleText;
  }

  static const String sampleText = '''
부동산 매물 캡쳐
서울시 강남구 테헤란로 123 301호
전용 59.8m2 / 관리비 15만원
역삼역 도보 6분
참고 주소: 서울 강남구 테헤란로 123
''';
}

class MockOcrSource {
  static const String sample = 'mock://sample-capture';
}
