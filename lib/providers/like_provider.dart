import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final likeProvider = StateNotifierProvider.family<LikeNotifier, LikeState, String>(
  (ref, postId) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return LikeNotifier(postId: postId, userId: userId);
  },
);

class LikeState {
  final bool isLiked;
  final int likeCount;
  final bool isLoading;
  final String? errorMessage;

  LikeState({
    required this.isLiked,
    required this.likeCount,
    this.isLoading = false,
    this.errorMessage,
  });
}

class LikeNotifier extends StateNotifier<LikeState> {
  final String postId;
  final String userId;

  LikeNotifier({required this.postId, required this.userId})
      : super(LikeState(isLiked: false, likeCount: 0, isLoading: true)) {
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    try {
      final userLikedPostsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('likedPosts')
          .doc(postId);

      final likedDoc = await userLikedPostsRef.get();
      final isLiked = likedDoc.exists;

      final postLikesRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes');
      final likeCount = (await postLikesRef.get()).size;

      state = LikeState(isLiked: isLiked, likeCount: likeCount, isLoading: false);
    } catch (e) {
      state = LikeState(
        isLiked: false,
        likeCount: 0,
        isLoading: false,
        errorMessage: 'Failed to load like status: $e',
      );
    }
  }

  Future<void> toggleLike() async {
    try {
      state = LikeState(
        isLiked: state.isLiked,
        likeCount: state.likeCount,
        isLoading: true,
      );

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

      if (state.isLiked) {
        await userLikedPostsRef.delete();
        await postLikesRef.delete();
        state = LikeState(
          isLiked: false,
          likeCount: state.likeCount - 1,
          isLoading: false,
        );
      } else {
        await userLikedPostsRef.set({'liked': true});
        await postLikesRef.set({'userId': userId});
        state = LikeState(
          isLiked: true,
          likeCount: state.likeCount + 1,
          isLoading: false,
        );
      }
    } catch (e) {
      state = LikeState(
        isLiked: state.isLiked,
        likeCount: state.likeCount,
        isLoading: false,
        errorMessage: 'Failed to toggle like: $e',
      );
    }
  }
}
