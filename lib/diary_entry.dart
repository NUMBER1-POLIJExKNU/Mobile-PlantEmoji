class DiaryEntry {
  final String id;
  final String date;
  final String stage;
  final String quote;
  final double? heightCm;
  final int? leafCount;
  final String? photoUrl;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.stage,
    required this.quote,
    this.heightCm,
    this.leafCount,
    this.photoUrl,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      stage: json['stage'] ?? '',
      quote: json['quote'] ?? '',
      heightCm: json['height_cm'] != null ? (json['height_cm'] as num).toDouble() : null,
      leafCount: json['leaf_count'] != null ? (json['leaf_count'] as num).toInt() : null,
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'quote': quote,
      'height_cm': heightCm,
      'leaf_count': leafCount,
      'photo_url': photoUrl,
    };
  }
}
