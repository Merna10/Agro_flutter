import 'dart:io';

import 'package:crops/features/posts/data/model/post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final TextEditingController _postController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _imagePaths = [];

  Future<void> _getImages(ImageSource source) async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imagePaths.addAll(pickedFiles.map((pickedFile) => pickedFile.path));
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  void _submitPost(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final scaffoldMsg = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final List<String> imageUrls = [];

      for (final imagePath in _imagePaths) {
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('postImages')
            .child('$fileName.jpg');

        await storageRef.putFile(File(imagePath));
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      Post newPost = Post(
        postId: '',
        text: _postController.text.trim(),
        createdAt: Timestamp.now(),
        userId: currentUser.uid,
        username: userData['username'],
        userImage: userData['userImage'],
        postImages: imageUrls,
      );

      DocumentReference postRef = await FirebaseFirestore.instance
          .collection('posts')
          .add(newPost.toMap());

      await postRef.update({'postId': postRef.id});

      _postController.clear();
      scaffoldMsg.showSnackBar(
        const SnackBar(
          content: Text('Post added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _imagePaths.clear();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color.fromARGB(255, 26, 115, 44)
                          .withOpacity(0.8);
                    }
                    return const Color.fromARGB(255, 26, 115, 44);
                  },
                ),
              ),
              onPressed: () => _isSubmitting ? null : _submitPost(context),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Post',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _postController,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16.0),
              if (_imagePaths.isNotEmpty)
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  children: _imagePaths.map((imagePath) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _getImageFromCamera(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.red,
                          size: 25,
                        ),
                        SizedBox(width: 10),
                        Text('Camera',
                            style: TextStyle(
                                color: Color.fromARGB(255, 155, 152, 152),
                                fontSize: 15)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () => _getImages(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.image, color: Colors.blue, size: 23),
                        SizedBox(width: 10),
                        Text('Gallery/Photos',
                            style: TextStyle(
                                color: Color.fromARGB(255, 155, 152, 152),
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
