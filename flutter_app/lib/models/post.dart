class Post {
  final int? id;
  final int userId;
  final String pictureUrl;
  final String description;

  Post({
    this.id,
    required this.userId,
    required this.pictureUrl,
    required this.description,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      userId: json['userId'] as int? ?? 0,
      pictureUrl: json['pictureUrl'] ?? 'assets/images/default.png',
      description: json['description'] ?? '',
    );
  }
}