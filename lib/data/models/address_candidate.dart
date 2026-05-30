class AddressCandidate {
  const AddressCandidate({
    required this.id,
    required this.rawText,
    required this.normalizedAddress,
    required this.confidence,
    this.detailAddress,
    this.latitude,
    this.longitude,
    this.province,
    this.district,
    this.locality,
  });

  final String id;
  final String rawText;
  final String normalizedAddress;
  final int confidence;
  final String? detailAddress;
  final double? latitude;
  final double? longitude;
  final String? province;
  final String? district;
  final String? locality;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawText': rawText,
      'normalizedAddress': normalizedAddress,
      'confidence': confidence,
      'detailAddress': detailAddress,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'district': district,
      'locality': locality,
    };
  }

  factory AddressCandidate.fromJson(Map<String, dynamic> json) {
    return AddressCandidate(
      id: json['id'] as String,
      rawText: json['rawText'] as String,
      normalizedAddress: json['normalizedAddress'] as String,
      confidence: json['confidence'] as int,
      detailAddress: json['detailAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      province: json['province'] as String?,
      district: json['district'] as String?,
      locality: json['locality'] as String?,
    );
  }
}
