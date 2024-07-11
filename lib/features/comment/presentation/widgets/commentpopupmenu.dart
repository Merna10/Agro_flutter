import 'package:crops/features/comment/presentation/screens/edit_comment.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showCommentPopupMenu(
  BuildContext context,
  Offset offset,
  String commenterId,
  String postId,
  String commentId,
  String commentText,
  List<String> imageUrls,
  String postOwnerId,
) {
  final currentUser = FirebaseAuth.instance.currentUser;
  final isCommenter = currentUser?.uid == commenterId;

  if (!isCommenter && currentUser?.uid != postOwnerId) {
    return;
  }

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
    items: [
      if (isCommenter || currentUser?.uid == postOwnerId)
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      if (isCommenter)
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
    ],
    elevation: 8.0,
  ).then((value) {
    if (value == 'delete') {
      try {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .delete();
      } catch (e) {
        print('Error deleting comment: $e');
      }
    } else if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditCommentScreen(
            postId: postId,
            commentId: commentId,
            commentText: commentText,
            commentImage: imageUrls,
          ),
        ),
      );
    }
  });
}

void showRepliesPopupMenu(
  BuildContext context,
  Offset offset,
  String commenterId,
  String postId,
  String commentId,
  String replyId,
  String commentText,
  List<String> imageUrls,
  String postOwnerId,
) {
  final currentUser = FirebaseAuth.instance.currentUser;
  final isPostOwner = currentUser != null && currentUser.uid == postOwnerId;
  final isCommenter = currentUser != null && currentUser.uid == commenterId;

  if (!isPostOwner && !isCommenter) {
    return;
  }

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
    items: [
      if (isPostOwner || isCommenter)
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      if (isCommenter)
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
    ],
    elevation: 8.0,
  ).then((value) {
    if (value == 'delete') {
      try {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .delete();
      } catch (e) {
        print('Error deleting reply: $e');
      }
    } else if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRepliesScreen(
            postId: postId,
            commentId: commentId,
            commentText: commentText,
            commentImage: imageUrls,
            replyId: replyId,
          ),
        ),
      );
    }
  });
}
