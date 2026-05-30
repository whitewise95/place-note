class SummaryCard {
  const SummaryCard({
    required this.title,
    required this.value,
    required this.description,
    required this.status,
  });

  final String title;
  final String value;
  final String description;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'description': description,
      'status': status,
    };
  }

  factory SummaryCard.fromJson(Map<String, dynamic> json) {
    return SummaryCard(
      title: json['title'] as String,
      value: json['value'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
    );
  }
}

class ResearchReport {
  const ResearchReport({
    required this.id,
    required this.rawAddress,
    required this.normalizedAddress,
    required this.summaryCards,
    required this.status,
    required this.createdAt,
    this.folderId = 'folder-inbox',
    this.imagePath,
    this.ocrText,
    this.detailAddress,
    this.latitude,
    this.longitude,
    this.province,
    this.district,
    this.locality,
    this.isSaved = false,
  });

  final String id;
  final String rawAddress;
  final String normalizedAddress;
  final List<SummaryCard> summaryCards;
  final String status;
  final DateTime createdAt;
  final String folderId;
  final String? imagePath;
  final String? ocrText;
  final String? detailAddress;
  final double? latitude;
  final double? longitude;
  final String? province;
  final String? district;
  final String? locality;
  final bool isSaved;

  ResearchReport copyWith({bool? isSaved, String? folderId}) {
    return ResearchReport(
      id: id,
      rawAddress: rawAddress,
      normalizedAddress: normalizedAddress,
      summaryCards: summaryCards,
      status: status,
      createdAt: createdAt,
      folderId: folderId ?? this.folderId,
      imagePath: imagePath,
      ocrText: ocrText,
      detailAddress: detailAddress,
      latitude: latitude,
      longitude: longitude,
      province: province,
      district: district,
      locality: locality,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawAddress': rawAddress,
      'normalizedAddress': normalizedAddress,
      'summaryCards': summaryCards.map((card) => card.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'folderId': folderId,
      'imagePath': imagePath,
      'ocrText': ocrText,
      'detailAddress': detailAddress,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'district': district,
      'locality': locality,
      'isSaved': isSaved,
    };
  }

  factory ResearchReport.fromJson(Map<String, dynamic> json) {
    return ResearchReport(
      id: json['id'] as String,
      rawAddress: json['rawAddress'] as String,
      normalizedAddress: json['normalizedAddress'] as String,
      summaryCards: (json['summaryCards'] as List<dynamic>)
          .map((card) => SummaryCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      folderId: json['folderId'] as String? ?? 'folder-inbox',
      imagePath: json['imagePath'] as String?,
      ocrText: json['ocrText'] as String?,
      detailAddress: json['detailAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      province: json['province'] as String?,
      district: json['district'] as String?,
      locality: json['locality'] as String?,
      isSaved: json['isSaved'] as bool? ?? true,
    );
  }
}
