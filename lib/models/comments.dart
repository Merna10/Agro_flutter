class Comment {
  final String userId;
  final String comment;
  final DateTime createdAt;
  final List<String> postImages;
  

  Comment({
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.postImages,
  });
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comment': comment,
      'createdAt': createdAt,
      'postImages': postImages,
    };
  }
}
