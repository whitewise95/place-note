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
    this.imagePath,
    this.ocrText,
    this.detailAddress,
    this.isSaved = false,
  });

  final String id;
  final String rawAddress;
  final String normalizedAddress;
  final List<SummaryCard> summaryCards;
  final String status;
  final DateTime createdAt;
  final String? imagePath;
  final String? ocrText;
  final String? detailAddress;
  final bool isSaved;

  ResearchReport copyWith({bool? isSaved}) {
    return ResearchReport(
      id: id,
      rawAddress: rawAddress,
      normalizedAddress: normalizedAddress,
      summaryCards: summaryCards,
      status: status,
      createdAt: createdAt,
      imagePath: imagePath,
      ocrText: ocrText,
      detailAddress: detailAddress,
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
      'imagePath': imagePath,
      'ocrText': ocrText,
      'detailAddress': detailAddress,
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
      imagePath: json['imagePath'] as String?,
      ocrText: json['ocrText'] as String?,
      detailAddress: json['detailAddress'] as String?,
      isSaved: json['isSaved'] as bool? ?? true,
    );
  }
}
