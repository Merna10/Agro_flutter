import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButtonComment extends StatefulWidget {
  final String commentId, postId;

  const LikeButtonComment({
    required this.postId,
    required this.commentId,
    super.key,
  });

  @override
  State<LikeButtonComment> createState() => _LikeButtonCommentState();
}

class _LikeButtonCommentState extends State<LikeButtonComment> {
  bool _isLiked = false;
  @override
  void initState() {
    super.initState();
    _loadLikeStatus();

    _getDocumentCount();
  }

  Future<void> _loadLikeStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserUid = currentUser?.uid;

    if (currentUserUid != null) {
      final userLikedCommentsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('likedComments')
          .doc(widget.commentId);

      final likedDoc = await userLikedCommentsRef.get();
      final alreadyLiked = likedDoc.exists;

      setState(() {
        _isLiked = alreadyLiked;
      });
    }
  }

  int _documentCount = 0;
  Future<void> _getDocumentCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('likes')
        .get();

    setState(() {
      _documentCount = querySnapshot.size;
    });
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserUid = currentUser?.uid;

    if (currentUserUid != null) {
      final userLikedCommentsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('likedComments')
          .doc(widget.commentId);

      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('likes')
          .doc(currentUserUid);

      final likedDoc = await userLikedCommentsRef.get();
      final alreadyLiked = likedDoc.exists;

      if (alreadyLiked) {
        await userLikedCommentsRef.delete();
        await commentRef.delete();
        setState(() {
          _isLiked = false;
        });
      } else {
        await userLikedCommentsRef.set({'liked': true});
        await commentRef.set({'userId': currentUserUid});
        setState(() {
          _isLiked = true;
        });
      }
    }
    await _getDocumentCount();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final likes = _documentCount;

          bool isLiked = _isLiked;
          if (FirebaseAuth.instance.currentUser == null) {
            isLiked = false;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _toggleLike,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  side: BorderSide.none,
                ),
                child: Text(
                  isLiked ? '$likes Liked' : '$likes Like',
                  style: TextStyle(
                    fontSize: 15,
                    color: isLiked
                        ? const Color.fromARGB(255, 26, 115, 44)
                        : Colors.black,
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading like count');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
