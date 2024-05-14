import 'dart:io';

import 'package:crops/widgets/edit_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/screens/profile.dart';
import 'package:crops/screens/repliesscreen.dart';
import 'package:crops/widgets/image_viewer.dart';
import 'package:crops/widgets/likebutton.dart';
import 'package:crops/widgets/likecomment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

class AddCommentScreen extends StatefulWidget {
  const AddCommentScreen({
    super.key,
    required this.postId,
    required this.userId,
  });

  final String postId;
  final String userId;

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<File> _images = [];
  String dropdownValue = 'Camera';

  Future<void> _getImages(ImageSource source) async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
    });
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _addComment() async {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      try {
        final List<String> imageUrls = [];

        for (final imageFile in _images) {
          final String fileName = const Uuid().v4();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('postImages')
              .child('$fileName.jpg');

          await storageRef.putFile(imageFile);
          final imageUrl = await storageRef.getDownloadURL();
          imageUrls.add(imageUrl);
        }
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'userId': widget.userId,
          'comment': commentText,
          'createdAt': Timestamp.now(),
          'postImages': imageUrls,
        });
        _commentController.clear();

        setState(() {
          _images.clear();
        });
      } catch (e) {
        //
      }
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      await Future.delayed(
        const Duration(seconds: 2),
      );
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
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

  Future<void> _editComment(String commentId, String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({'comment': newText});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating comment: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot> postSnapshot) {
                      if (postSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (postSnapshot.hasError) {
                        return const Center(
                            child: Text('Error fetching post data'));
                      } else if (!postSnapshot.hasData) {
                        return const Center(child: Text('Post not found'));
                      }

                      var postData =
                          postSnapshot.data!.data() as Map<String, dynamic>;
                      String postText = postData['text'] ?? '';
                      String postOwnerName = postData['username'] ?? 'Unknown';
                      String postOwnerImage = postData['userImage'] ?? '';

                      List<String> postImageUrl = [];
                      if (postData['postImages'] != null &&
                          (postData['postImages'] as List).isNotEmpty) {
                        postImageUrl =
                            List<String>.from(postData['postImages']);
                      }

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
                              title: Text(
                                postOwnerName,
                              ),
                              subtitle: Text(
                                DateFormat('dd MMMM yyyy HH:mm')
                                    .format(postData['createdAt'].toDate()),
                              ),
                              trailing: postData['userId'] ==
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
                                              builder: (context) =>
                                                  EditPostScreen(
                                                postId: widget.postId,
                                                postText: postText,
                                                postImages: postImageUrl,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          deletePost(widget.postId);
                                        }
                                      },
                                    )
                                  : null,
                              onTap: () async {
                                DocumentSnapshot userData =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.userId)
                                        .get();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfile(userData: userData),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              postText,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (postImageUrl.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                          imageUrls: postImageUrl,
                                          initialIndex: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: postImageUrl.length == 1
                                      ? Container(
                                          height: 250,
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          margin: const EdgeInsets.all(4),
                                          child: Image.network(
                                            postImageUrl.first,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 4,
                                          ),
                                          itemCount: postImageUrl.length > 2
                                              ? 2
                                              : postImageUrl.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.all(4),
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: postImageUrl[index],
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              if (postImageUrl.length > 2)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                          imageUrls: postImageUrl,
                                          initialIndex: 0,
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
                                        '+${postImageUrl.length - 2}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          LikeButton(
                            postId: widget.postId,
                            userId:
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Comments:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.postId)
                                .collection('comments')
                                .orderBy(
                                  'createdAt',
                                  descending: true,
                                )
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Error fetching comments'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text('No comments yet'),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final comment = snapshot.data!.docs[index];
                                  String commenterId = comment['userId'];
                                  String commentText = comment['comment'];
                                  List<String> commetImageUrl = [];
                                  if (comment['postImages'] != null &&
                                      (comment['postImages'] as List)
                                          .isNotEmpty) {
                                    commetImageUrl = List<String>.from(
                                        comment['postImages']);
                                  }
                                  Timestamp commentCreatedAt =
                                      comment['createdAt'];

                                  String formattedCommentDate =
                                      DateFormat('dd MMMM yyyy')
                                          .format(commentCreatedAt.toDate());

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(commenterId)
                                        .get(),
                                    builder: (context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (userSnapshot.hasError) {
                                        return const Text(
                                            'Error fetching user data');
                                      } else if (!userSnapshot.hasData ||
                                          !userSnapshot.data!.exists) {
                                        return const Text(
                                            'User data not found');
                                      }

                                      var userData = userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                      String commenterName =
                                          userData['username'] ?? 'Unknown';
                                      String commenterImage =
                                          userData['image_url'] ?? '';

                                      return ListTile(
                                        leading: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: commenterImage,
                                          height: 50,
                                          width: 50,
                                        ),
                                        title: Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.sizeOf(context)
                                                  .width,
                                              padding: const EdgeInsets.only(
                                                  bottom: 15,
                                                  left: 15,
                                                  top: 15),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color.fromARGB(
                                                      42, 158, 158, 158)),
                                              child: Stack(
                                                children: [
                                                  if (comment['userId'] ==
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid)
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          PopupMenuButton<
                                                              String>(
                                                            itemBuilder: (BuildContext
                                                                    context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                              const PopupMenuItem<
                                                                  String>(
                                                                value: 'edit',
                                                                child: ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .edit),
                                                                  title: Text(
                                                                      'Edit'),
                                                                ),
                                                              ),
                                                              const PopupMenuItem<
                                                                  String>(
                                                                value: 'delete',
                                                                child: ListTile(
                                                                  leading: Icon(
                                                                      Icons
                                                                          .delete),
                                                                  title: Text(
                                                                      'Delete'),
                                                                ),
                                                              ),
                                                            ],
                                                            onSelected:
                                                                (String value) {
                                                              if (value ==
                                                                  'edit') {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    String
                                                                        updatedText =
                                                                        '';
                                                                    return AlertDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      title:
                                                                          const Text(
                                                                        'Edit Comment',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                'Georgia',
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                26,
                                                                                115,
                                                                                44)),
                                                                      ),
                                                                      content:
                                                                          TextField(
                                                                        textCapitalization:
                                                                            TextCapitalization.sentences,
                                                                        maxLines:
                                                                            null,
                                                                        textInputAction:
                                                                            TextInputAction.newline,
                                                                        onChanged:
                                                                            (value) {
                                                                          updatedText =
                                                                              value;
                                                                        },
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            _editComment(comment.id,
                                                                                updatedText);
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Save',
                                                                            style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontFamily: 'Georgia',
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color.fromARGB(255, 26, 115, 44)),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Cancel',
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontFamily: 'Georgia',
                                                                                color: HexColor('#44ac5c')),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else if (value ==
                                                                  'delete') {
                                                                deleteComment(
                                                                    comment.id);
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  Text(
                                                    commentText ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      overflow:
                                                          TextOverflow.visible,
                                                    ),
                                                    maxLines: null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (commetImageUrl.isNotEmpty)
                                              commetImageUrl.length == 1
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ImageViewer(
                                                              imageUrls:
                                                                  commetImageUrl,
                                                              initialIndex:
                                                                  index,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(4),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            commetImageUrl
                                                                .first,
                                                            width: MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width,
                                                            height: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .height *
                                                                0.18,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ImageViewer(
                                                              imageUrls:
                                                                  commetImageUrl,
                                                              initialIndex:
                                                                  index,
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
                                                        itemCount: commetImageUrl
                                                                    .length >
                                                                2
                                                            ? 2
                                                            : commetImageUrl
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  Image.network(
                                                                commetImageUrl[
                                                                    index],
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                            if (commetImageUrl.length > 2)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageViewer(
                                                        imageUrls:
                                                            commetImageUrl,
                                                        initialIndex: 0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '+${commetImageUrl.length - 2}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ' $commenterName - $formattedCommentDate',
                                            ),
                                            Row(
                                              children: [
                                                LikeButtonComment(
                                                    postId: widget.postId,
                                                    commentId: comment.id),
                                                TextButton(
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    26,
                                                                    115,
                                                                    44)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReplyScreen(
                                                          commentId: comment.id,
                                                          postId: widget.postId,
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
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Enter your comment',
                  ),
                ),
                const SizedBox(height: 16),
                if (_images.isNotEmpty)
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    children: _images.map((image) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                        if (newValue == 'Camera') {
                          _getImageFromCamera();
                        } else if (newValue == 'Gallery/Photos') {
                          _getImages(ImageSource.gallery);
                        }
                      },
                      items: <String>['Camera', 'Gallery/Photos']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              value == 'Camera'
                                  ? const Icon(
                                      Icons.camera_alt,
                                      color: Colors.red,
                                      size: 25,
                                    )
                                  : const Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                      size: 23,
                                    ),
                              const SizedBox(width: 10),
                              Text(value,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      width: 76,
                    ),
                    ElevatedButton(
                      onPressed: _addComment,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color.fromARGB(255, 26, 115, 44)
                                  .withOpacity(0.8);
                            }
                            return const Color.fromARGB(255, 26, 115, 44);
                          },
                        ),
                      ),
                      child: const Text(
                        'Add Comment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
