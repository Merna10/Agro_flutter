import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userImage;
  final String username;
  final String text;
  final String userId;
  final Timestamp createdAt;
  final List<String> postImages;

  Post({
    required this.postId,
    required this.userImage,
    required this.username,
    required this.text,
    required this.userId,
    required this.createdAt,
    required this.postImages,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId':postId,
      'text': text,
      'createdAt': createdAt,
      'userId': userId,
      'username': username,
      'userImage': userImage,
      'postImages': postImages,
    };
  }

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.id, // Use the document ID as the postId
      userImage: doc['userImage'],
      username: doc['username'],
      text: doc['text'],
      userId: doc['userId'],
      createdAt: doc['createdAt'],
      postImages: List<String>.from(doc['postImages']),
    );
  }
}
