import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final commentsStreamProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: true)
      .snapshots();
});

