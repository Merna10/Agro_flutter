import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikeNotifier extends StateNotifier<bool> {
  final String postId;
  final String userId;

  LikeNotifier({required this.postId, required this.userId}) : super(false) {
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final userLikedPostsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likedPosts')
        .doc(postId);

    final likedDoc = await userLikedPostsRef.get();
    state = likedDoc.exists;
  }

  Future<void> toggleLike() async {
    final postLikesRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final userLikedPostsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likedPosts')
        .doc(postId);

    if (state) {
      await userLikedPostsRef.delete();
      await postLikesRef.delete();
      state = false;
    } else {
      await userLikedPostsRef.set({'liked': true});
      await postLikesRef.set({'userId': userId});
      state = true;
    }
  }
}
