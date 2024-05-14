import 'package:crops/screens/addcomment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final String userId;

  const LikeButton({
    super.key,
    required this.postId,
    required this.userId,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
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
      final userLikedPostsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('likedPosts')
          .doc(widget.postId);

      final likedDoc = await userLikedPostsRef.get();
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
      final userLikedPostsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('likedPosts')
          .doc(widget.postId);

      final postLikesRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('likes')
          .doc(currentUserUid);

      final likedDoc = await userLikedPostsRef.get();
      final alreadyLiked = likedDoc.exists;

      if (alreadyLiked) {
        await userLikedPostsRef.delete();
        await postLikesRef.delete();
        setState(() {
          _isLiked = false;
        });
      } else {
        await userLikedPostsRef.set({'liked': true});
        await postLikesRef.set({'userId': currentUserUid});
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final likes = _documentCount;

          bool isLiked = _isLiked;
          if (FirebaseAuth.instance.currentUser == null) {
            isLiked = false;
          }

          return Row(
            children: [
              const Divider(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.green : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$likes Likes'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.comment,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCommentScreen(
                              postId: widget.postId,
                              userId: FirebaseAuth.instance.currentUser!.uid,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
