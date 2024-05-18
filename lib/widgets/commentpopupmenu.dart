import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/widgets/edit_comment.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommmentPopupMenu extends StatelessWidget {
  final String userId;
  final String postId;
  final String commentId;
  final String commentText;
  final List<String> imageUrls;

  const CommmentPopupMenu({
    super.key,
    required this.userId,
    required this.postId,
    required this.commentId,
    required this.commentText,
    required this.imageUrls,
  });

  Future<void> deleteComment(BuildContext context, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting comment: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (userId == FirebaseAuth.instance.currentUser?.uid)
          const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
        
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
            ),
          ),
      ],
      onSelected: (String value) {
        if (value == 'edit') {
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
        } else if (value == 'delete') {
          deleteComment(context, commentId);
        }
      },
    );
  }
}
