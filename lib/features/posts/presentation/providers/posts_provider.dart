import 'package:crops/features/posts/data/model/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final postProvider =
    FutureProvider.autoDispose.family<DocumentSnapshot, String>((ref, postId) {
  return FirebaseFirestore.instance.collection('posts').doc(postId).get();
});

final postsStreamProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final postsCollection = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true);

  return postsCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  });
});

final userPostsStreamProvider =
    StreamProvider.family<List<Post>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  }).handleError((error) {
    print('Error fetching post data: $error');
  });
});
