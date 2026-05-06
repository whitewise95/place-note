class AddressCandidate {
  const AddressCandidate({
    required this.id,
    required this.rawText,
    required this.normalizedAddress,
    required this.confidence,
    this.detailAddress,
  });

  final String id;
  final String rawText;
  final String normalizedAddress;
  final int confidence;
  final String? detailAddress;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawText': rawText,
      'normalizedAddress': normalizedAddress,
      'confidence': confidence,
      'detailAddress': detailAddress,
    };
  }

  factory AddressCandidate.fromJson(Map<String, dynamic> json) {
    return AddressCandidate(
      id: json['id'] as String,
      rawText: json['rawText'] as String,
      normalizedAddress: json['normalizedAddress'] as String,
      confidence: json['confidence'] as int,
      detailAddress: json['detailAddress'] as String?,
    );
  }
}
