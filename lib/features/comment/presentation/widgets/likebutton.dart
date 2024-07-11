import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/features/comment/presentation/screens/comment_list.dart';
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

    _getLikesCount();
    _getCommentsCount();
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

  int _likesCount = 0;
  Future<void> _getLikesCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .get();

    setState(() {
      _likesCount = querySnapshot.size;
    });
  }

  int _commentsCount = 0;
  Future<void> _getCommentsCount() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .get();

    setState(() {
      _commentsCount = querySnapshot.size;
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
    await _getLikesCount();
    await _getCommentsCount();
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
          final likes = _likesCount;
          final comments = _commentsCount;

          bool isLiked = _isLiked;
          if (FirebaseAuth.instance.currentUser == null) {
            isLiked = false;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$likes Likes $comments Comments',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 177, 198, 180),
                    fontSize: 12,
                  ),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Divider(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _toggleLike,
                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_alt_outlined,
                            color: isLiked
                                ? Colors.green
                                : const Color.fromARGB(255, 122, 126, 122),
                          ),
                          label: Text(
                            isLiked ? ' Liked' : 'Like',
                            style: TextStyle(
                              color: isLiked
                                  ? Colors.green
                                  : const Color.fromARGB(255, 122, 126, 122),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentScreen(
                                  postId: widget.postId,
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.comment,
                            size: 20,
                            color: const Color.fromARGB(255, 122, 126, 122),
                          ),
                          label: const Text(
                            'Comment',
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 122, 126, 122)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
