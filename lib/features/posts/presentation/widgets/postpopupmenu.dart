import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/features/posts/presentation/widgets/edit_post.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPopupMenu extends StatelessWidget {
  final String? userId;
  final String postId;
  final String postText;
  final List<String> imageUrls;

  const PostPopupMenu({
    super.key,
    required this.userId,
    required this.postId,
    required this.postText,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (userId == FirebaseAuth.instance.currentUser?.uid) {
          return PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                    builder: (context) => EditPostScreen(
                      postId: postId,
                      postText: postText,
                      postImages: imageUrls,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                deletePost(context, postId);
              }
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      await FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((postsSnapshot) {
        for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('comments')
              .get()
              .then((commentsSnapshot) {
            for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
              commentDoc.reference.delete();
            }
          });
        }
      });
      await FirebaseFirestore.instance
          .collection('posts')
          .get()
          .then((postsSnapshot) {
        for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(postDoc.id)
              .collection('likes')
              .get()
              .then((commentsSnapshot) {
            for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
              commentDoc.reference.delete();
            }
          });
        }
      });

      if (postDoc.exists) {
        await postRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post does not exist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
