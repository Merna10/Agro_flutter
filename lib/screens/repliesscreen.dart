import 'dart:io';

import 'package:crops/widgets/commentpopupmenu.dart';
import 'package:crops/widgets/image_grid.dart';
import 'package:crops/widgets/image_viewer.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ReplyScreen extends StatefulWidget {
  final String commentId, postId;

  const ReplyScreen({Key? key, required this.commentId, required this.postId})
      : super(key: key);

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController _replyController = TextEditingController();
  final List<File> _images = [];
  String dropdownValue = 'Camera';

  Future<void> deleteReply(String replyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('replies')
          .doc(replyId)
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

  Future<void> _editComment(String replyId, String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('replies')
          .doc(replyId)
          .update({'text': newText});
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

  Future<void> _addReply(String replyText) async {
    if (replyText.isNotEmpty) {
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
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(widget.commentId)
            .collection('replies')
            .add({
          'userId': user?.uid,
          'text': replyText,
          'repliesImages': imageUrls,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Handle error
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(widget.commentId)
                    .collection('replies')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No replies yet.'));
                  }
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final replyData = snapshot.data!.docs[index];
                          List<String> repliesImagesUrl = [];
                          if (replyData['repliesImages'] != null &&
                              (replyData['repliesImages'] as List).isNotEmpty) {
                            repliesImagesUrl =
                                List<String>.from(replyData['repliesImages']);
                          }
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(replyData['userId'])
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (userSnapshot.hasError) {
                                return const Text('Error fetching user data');
                              } else if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const Text('User data not found');
                              }

                              var userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              String commenterName =
                                  userData['username'] ?? 'Unknown';
                              String commenterImage =
                                  userData['userImage'] ?? '';

                              return ListTile(
                                title: Column(children: [
                                  Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    padding: const EdgeInsets.only(
                                        bottom: 15, left: 15, top: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color.fromARGB(
                                          42, 158, 158, 158),
                                    ),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onLongPressStart:
                                              (LongPressStartDetails details) {
                                            // Access details here, such as details.globalPosition
                                            showRepliesPopupMenu(
                                              context,
                                              details.globalPosition,
                                              replyData['userId'],
                                              widget.postId,
                                              widget.commentId,
                                              replyData.id,
                                              replyData['text'],
                                              repliesImagesUrl,
                                              replyData['userId'],
                                            );
                                          },
                                          child: Text(
                                            replyData['text'],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              overflow: TextOverflow.visible,
                                            ),
                                            maxLines: null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ImageGrid(
                                      imageUrls: repliesImagesUrl, index: 0),
                                ]),
                                leading: Image.network(
                                  commenterImage,
                                  height: 50,
                                  width: 50,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        ' $commenterName -${_formatTimestamp(replyData['timestamp'])}'),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _replyController,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Enter your reply',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
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
                const SizedBox(height: 16),
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
                              Text(value, style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      width: 36,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String replyText = _replyController.text.trim();
                        if (replyText.isNotEmpty) {
                          await _addReply(replyText);
                          _replyController.clear();
                        }
                      },
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
                        'Add Reply',
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown';
    }
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
