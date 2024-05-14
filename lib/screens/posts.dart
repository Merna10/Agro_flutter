import 'package:crops/widgets/edit_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/screens/profile.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import '../widgets/image_viewer.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> deletePost(String postId) async {
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching data'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.pixels);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];
            String postId = document.id;
            String userId = document['userId'];
            List<String> imageUrls = [];

            if (document['postImages'] != null &&
                (document['postImages'] as List).isNotEmpty) {
              imageUrls = List<String>.from(document['postImages']);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: document['userImage'],
                    height: 60,
                    width: 50,
                  ),
                  title: Text(document['username']),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy HH:mm')
                        .format(document['createdAt'].toDate()),
                  ),
                  trailing: document['userId'] ==
                          FirebaseAuth.instance.currentUser?.uid
                      ? PopupMenuButton<String>(
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
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
                                    postId: document.id,
                                    postText: document['text'],
                                    postImages: imageUrls,
                                  ),
                                ),
                              );
                            } else if (value == 'delete') {
                              deletePost(postId);
                            }
                          },
                        )
                      : null,
                  onTap: () async {
                    DocumentSnapshot userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(userData: userData),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    document['text'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (imageUrls.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(
                            imageUrls: imageUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: imageUrls.length == 1
                        ? Container(
                            height: 250,
                            width: MediaQuery.sizeOf(context).width,
                            margin: const EdgeInsets.all(4),
                            child: Image.network(
                              imageUrls.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount:
                                imageUrls.length > 2 ? 2 : imageUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),
                if (imageUrls.length > 2)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewer(
                            imageUrls: imageUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '+${imageUrls.length - 2}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                LikeButton(
                  postId: postId,
                  userId: userId,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
