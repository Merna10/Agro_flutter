import 'package:crops/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/widgets/edit_post.dart';
import 'package:crops/screens/password_update_screen.dart';
import 'package:crops/screens/uodateprofile.dart';
import 'package:crops/widgets/image_viewer.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:crops/screens/new_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.userData});

  final DocumentSnapshot userData;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  List<DocumentSnapshot> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _fetchUserPosts();
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Confirm Account Deletion',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 26, 115, 44)),
            ),
            content: const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Rubik',
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 228, 9, 9)),
                ),
                onPressed: () {
                  deleteAccount(context);
                },
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      color: HexColor('#44ac5c')),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        String? password = await _showPasswordDialog(context);

        if (password != null) {
          AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!, password: password);
          await user.reauthenticateWithCredential(credential);

          await FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: user.uid)
              .get()
              .then((snapshot) {
            for (DocumentSnapshot doc in snapshot.docs) {
              doc.reference.delete();
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
                  .collection('comments')
                  .where('userId', isEqualTo: user.uid)
                  .get()
                  .then((commentsSnapshot) {
                for (QueryDocumentSnapshot commentDoc
                    in commentsSnapshot.docs) {
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
                  .where('userId', isEqualTo: user.uid)
                  .get()
                  .then((commentsSnapshot) {
                for (QueryDocumentSnapshot commentDoc
                    in commentsSnapshot.docs) {
                  commentDoc.reference.delete();
                }
              });
            }
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('likedPosts')
              .get()
              .then((likedPostsSnapshot) {
            for (QueryDocumentSnapshot likedPostDoc
                in likedPostsSnapshot.docs) {
              likedPostDoc.reference.delete();
            }
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('likedComments')
              .get()
              .then((likedPostsSnapshot) {
            for (QueryDocumentSnapshot likedPostDoc
                in likedPostsSnapshot.docs) {
              likedPostDoc.reference.delete();
            }
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();

          await user.delete();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'An error occurred while deleting your account.';
      if (e is FirebaseAuthException) {
        errorMessage = e.message!;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Enter Password',
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 115, 44)),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Confirm',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 228, 9, 9)),
              ),
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: HexColor('#44ac5c')),
              ),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      _fetchUserPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchUserPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .where('userId', isEqualTo: widget.userData.id)
        .get();

    setState(() {
      _userPosts = querySnapshot.docs;
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
            if (FirebaseAuth.instance.currentUser?.uid == widget.userData.id)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewPost(),
                            ),
                          );
                          setState(() {
                            _fetchUserPosts();
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                      PopupMenuButton<String>(
                        color: HexColor('#ffffff'),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'editProfile',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'changePassword',
                            child: ListTile(
                              leading: Icon(Icons.vpn_key),
                              title: Text('Change Password'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'deleteAccount',
                            child: ListTile(
                              leading: Icon(Icons.delete_forever),
                              title: Text('Delete Account'),
                            ),
                          ),
                        ],
                        onSelected: (String value) {
                          if (value == 'editProfile') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  userId: widget.userData.id,
                                  username: widget.userData['username'],
                                  userImage: widget.userData['image_url'],
                                ),
                              ),
                            );
                            setState(() async {
                              UserProfile(
                                  userData: await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userData.id)
                                      .get());
                            });
                          } else if (value == 'changePassword') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PasswordUpdateScreen(),
                              ),
                            );
                          } else if (value == 'deleteAccount') {
                            showConfirmationDialog(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 15),
        height: MediaQuery.of(context).size.height,
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
                  _buildUserProfile(),
                  _buildUserPosts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    String avatarUrl = widget.userData['image_url'] ?? '';
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
          const SizedBox(
            height: 10,
          ),
          Text(
            '${widget.userData['username']}',
            style: TextStyle(
              fontSize: 22,
              color: HexColor('#1e3014'),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            ' ${widget.userData['email']}',
            style: TextStyle(
              fontSize: 16,
              color: HexColor('#bcd2d6'),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosts() {
    return Column(
      children: [
        if (_userPosts.isNotEmpty)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (FirebaseAuth.instance.currentUser?.uid ==
                    widget.userData.id)
                  const Divider(),
                SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userPosts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot post = _userPosts[index];
                      Timestamp createdAt = post['createdAt'];
                      DateTime dateTime = createdAt.toDate();
                      String formattedDate =
                          DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
                      List<String> imageUrls = [];
                      if (post['postImages'] != null &&
                          (post['postImages'] as List).isNotEmpty) {
                        imageUrls = List<String>.from(post['postImages']);
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: post['userImage'],
                                  height: 60,
                                  width: 50,
                                ),
                              ),
                              title: Text(
                                post['username'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(formattedDate),
                              onTap: () {},
                              trailing: post['userId'] ==
                                      FirebaseAuth.instance.currentUser?.uid
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PopupMenuButton<String>(
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
                                                  builder: (context) =>
                                                      EditPostScreen(
                                                    postId: post.id,
                                                    postText: post['text'],
                                                    postImages: imageUrls,
                                                  ),
                                                ),
                                              );
                                            } else if (value == 'delete') {
                                              deletePost(post.id);
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  post['text'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            if (post['postImages'] != null)
                              imageUrls.length == 1
                                  ? Container(
                                      height: 250,
                                      width: MediaQuery.sizeOf(context).width,
                                      margin: const EdgeInsets.all(4),
                                      child: Image.network(
                                        imageUrls.first,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: GestureDetector(
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
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 4,
                                          ),
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
                                          itemCount: imageUrls.length > 2
                                              ? 2
                                              : imageUrls.length,
                                        ),
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
                              postId: post.id,
                              userId:
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
