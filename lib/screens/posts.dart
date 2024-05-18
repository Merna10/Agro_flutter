import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/widgets/image_grid.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:crops/widgets/postpopupmenu.dart';
import 'package:crops/widgets/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crops/models/post.dart';
import 'package:crops/providers/posts_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:intl/intl.dart';

class PostsScreen extends ConsumerWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Post>> postsSnapshot = ref.watch(postsStreamProvider);

    return Scaffold(
      body: postsSnapshot.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: post.userImage,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    trailing: PostPopupMenu(
                        userId: post.userId,
                        postId: post.postId,
                        postText: post.text,
                        imageUrls: post.postImages),
                    title: Text(post.username),
                    subtitle: Text(
                      DateFormat('dd MMMM yyyy HH:mm')
                          .format(post.createdAt.toDate()),
                    ),
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(post.userId)
                          .get();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecificUserWidget(
                            userId: post.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  if (post.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.text,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ImageGrid(imageUrls: post.postImages, index: index),
                  LikeButton(
                    postId: post.postId,
                    userId:  FirebaseAuth.instance.currentUser?.uid ?? '',
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
