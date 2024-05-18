import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/providers/posts_provider.dart';
import 'package:crops/screens/add_comments.dart';
import 'package:crops/screens/repliesscreen.dart';
import 'package:crops/widgets/commentPopupMenu.dart';
import 'package:crops/widgets/image_grid.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:crops/widgets/likecomment.dart';
import 'package:crops/widgets/postpopupmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

final commentsStreamProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: true)
      .snapshots();
});

class CommentScreen extends ConsumerWidget {
  const CommentScreen({
    super.key,
    required this.postId,
    required this.userId,
  });

  final String postId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsStream = ref.watch(commentsStreamProvider(postId));
    final postFuture = ref.watch(postProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Comment'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  postFuture.when(
                    data: (postSnapshot) {
                      if (!postSnapshot.exists) {
                        return const Center(child: Text('Post not found'));
                      }
                      var postData =
                          postSnapshot.data() as Map<String, dynamic>;
                      String postText = postData['text'] ?? '';
                      String postOwnerName = postData['username'] ?? 'Unknown';
                      String postOwnerImage = postData['userImage'] ?? '';
                      List<String> postImageUrl =
                          List<String>.from(postData['postImages'] ?? []);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ListTile(
                              leading: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: postOwnerImage,
                                height: 200,
                                width: 100,
                              ),
                              title: Text(postOwnerName),
                              subtitle: Text(DateFormat('dd MMMM yyyy HH:mm')
                                  .format(postData['createdAt'].toDate())),
                              trailing: PostPopupMenu(
                                userId: postData['userId'],
                                postId: postId,
                                postText: postText,
                                imageUrls: postImageUrl,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(postText,
                                style: const TextStyle(fontSize: 18)),
                          ),
                          ImageGrid(imageUrls: postImageUrl, index: 0),
                          LikeButton(
                            postId: postId,
                            userId:
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Comments:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        const Center(child: Text('Error fetching post data')),
                  ),
                  commentsStream.when(
                    data: (snapshot) {
                      if (snapshot.docs.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.docs.length,
                        itemBuilder: (context, index) {
                          final comment = snapshot.docs[index];
                          return _buildCommentItem(context, comment);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        const Center(child: Text('Error fetching comments')),
                  ),
                ],
              ),
            ),
          ),
          AddComments(postId: postId, userId: userId),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context, QueryDocumentSnapshot comment) {
    String commenterId = comment['userId'];
    String commentText = comment['comment'];
    List<String> commentImageUrl =
        List<String>.from(comment['postImages'] ?? []);
    Timestamp commentCreatedAt = comment['createdAt'];
    String formattedCommentDate =
        DateFormat('dd MMMM yyyy').format(commentCreatedAt.toDate());

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(commenterId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (userSnapshot.hasError) {
          return const Text('Error fetching user data');
        } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Text('User data not found');
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        String commenterName = userData['username'] ?? 'Unknown';
        String commenterImage = userData['userImage'] ?? '';

        return ListTile(
          leading: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: commenterImage,
            height: 50,
            width: 50,
          ),
          title: Column(children: [
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.only(bottom: 15, left: 15, top: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(42, 158, 158, 158),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CommmentPopupMenu(
                      userId: commenterId,
                      postId: postId,
                      commentId: comment.id,
                      commentText: commentText,
                      imageUrls: commentImageUrl,
                    ),
                  ),
                  Text(
                    commentText,
                    style: const TextStyle(
                        fontSize: 17, overflow: TextOverflow.visible),
                    maxLines: null,
                  ),
                ],
              ),
            ),
            ImageGrid(imageUrls: commentImageUrl, index: 0),
          ]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$commenterName - $formattedCommentDate'),
              Row(
                children: [
                  LikeButtonComment(postId: postId, commentId: comment.id),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 26, 115, 44)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReplyScreen(
                            commentId: comment.id,
                            postId: postId,
                          ),
                        ),
                      );
                    },
                    child: const Text('Reply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
