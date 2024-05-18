import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/models/user.dart';
import 'package:crops/providers/posts_provider.dart';
import 'package:crops/screens/new_post.dart';
import 'package:crops/widgets/image_grid.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:crops/widgets/postpopupmenu.dart';
import 'package:crops/widgets/profilepopupmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:transparent_image/transparent_image.dart';

class UserProfile extends StatefulWidget {
  final Users user;
  final String userID;

  const UserProfile({super.key, required this.user, required this.userID});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  List userPosts = [];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _fetchUserPosts();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .where('userId', isEqualTo: widget.userID)
        .get();

    setState(() {
      userPosts = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(32.0),
        child: AppBar(
          backgroundColor: HexColor('#E7FEEB'),
          actions: [
            if (FirebaseAuth.instance.currentUser?.uid == widget.userID)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewPost(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                  ProfilePopupMenu(user: widget.user, userID: widget.userID),
                ],
              ),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        padding: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: HexColor('#E7FEEB'),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  buildUserProfile(),
                  buildUserPosts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserProfile() {
    String avatarUrl = widget.user.userImage;

    return Center(
      child: Column(
        children: [
          Text(
            "Welcome",
            style: GoogleFonts.atma(
              textStyle: TextStyle(
                fontSize: 80,
                color: HexColor('#44ac5c'),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 50,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.user.username,
            style: TextStyle(
              fontSize: 22,
              color: HexColor('#1e3014'),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 16,
              color: HexColor('#bcd2d6'),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          Center(
            child: Text(
              " Posts",
              style: GoogleFonts.atma(
                textStyle: TextStyle(
                  fontSize: 40,
                  color: HexColor('#44ac5c'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserPosts() {
    return Consumer(
      builder: (context, WidgetRef ref, child) {
        final postStream = ref.watch(userPostsStreamProvider(widget.userID));
        return postStream.when(
          data: (posts) {
            if (posts.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (FirebaseAuth.instance.currentUser?.uid ==
                          widget.userID)
                        const Divider(),
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
                          imageUrls: post.postImages,
                        ),
                        title: Text(
                          post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (post.text.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, bottom: 12.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              post.text,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 3.0),
                      ImageGrid(imageUrls: post.postImages, index: index),
                      LikeButton(postId: post.postId,userId:  FirebaseAuth.instance.currentUser?.uid ?? '',),
                    ],
                  );
                },
              );
            } else {
              return SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.45,
                child: const Center(
                    child: Text(
                  'No posts found',
                  style: TextStyle(
                      color: Color.fromARGB(255, 208, 213, 211), fontSize: 20),
                )),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, stackTrace) => Center(child: Text('Error: $e')),
        );
      },
    );
  }
}
