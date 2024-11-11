class Bookmark {
  final String imageUrl;
  final String title;

  Bookmark({required this.imageUrl, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      imageUrl: map['imageUrl'],
      title: map['title'],
    );
  }

  // Add equality comparison and hashcode overrides for proper comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.imageUrl == imageUrl &&
        other.title == title;
  }

  @override
  int get hashCode => imageUrl.hashCode ^ title.hashCode;
}
