class TextFolder {
  const TextFolder({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  static const String inboxId = 'folder-inbox';

  factory TextFolder.inbox() {
    return TextFolder(
      id: inboxId,
      name: '기본 보관함',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;

  TextFolder copyWith({
    String? name,
  }) {
    return TextFolder(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TextFolder.fromJson(Map<String, dynamic> json) {
    return TextFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
