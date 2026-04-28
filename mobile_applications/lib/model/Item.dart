class Item {
  final String id; // Unique identifier
  final String title;
  final String? imageUrl;
  final bool isFeatured;
  final String? source;
  final String? date;
  final String? body;

  const Item({
    required this.id,
    required this.title,
    this.imageUrl,
    this.isFeatured = false,
    this.source,
    this.date,
    this.body,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'source': source,
      'date': date,
      'body': body,
    };
  }

  // Create from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      source: json['source'] as String?,
      date: json['date'] as String?,
      body: json['body'] as String?,
    );
  }
}