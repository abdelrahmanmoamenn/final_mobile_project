import '../model/Item.dart';

class News {
  final int? id; // nullable for auto-increment
  final String title;
  final String description;
  final String? itemId;
  final String? imageUrl;
  final String? source;
  final String? date;
  final String? body;
  final bool isFeatured;

  const News({
    this.id,
    required this.title,
    required this.description,
    this.itemId,
    this.imageUrl,
    this.source,
    this.date,
    this.body,
    this.isFeatured = false,
  });

  /// Convert News object to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'itemId': itemId,
      'imageUrl': imageUrl,
      'source': source,
      'date': date,
      'body': body,
      'isFeatured': isFeatured ? 1 : 0,
    };
  }

  /// Create a News object from a database row
  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      itemId: map['itemId'] as String?,
      imageUrl: map['imageUrl'] as String?,
      source: map['source'] as String?,
      date: map['date'] as String?,
      body: map['body'] as String?,
      isFeatured: (map['isFeatured'] as int?) == 1,
    );
  }

  /// Create a News object from an Item (for migration purposes)
  factory News.fromItem(Item item) {
    return News(
      title: item.title,
      description: item.body ?? '',
      itemId: item.id,
      imageUrl: item.imageUrl,
      source: item.source,
      date: item.date,
      body: item.body,
      isFeatured: item.isFeatured,
    );
  }

  /// Convert News back to Item
  Item toItem() {
    return Item(
      id: itemId ?? title,
      title: title,
      imageUrl: imageUrl,
      source: source,
      date: date,
      body: body,
      isFeatured: isFeatured,
    );
  }
}

