import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:transparent_image/transparent_image.dart';

class EditCommentScreen extends StatefulWidget {
  final String postId;
  final String postText;
  final String? postImage;

  const EditCommentScreen({
    super.key,
    required this.postId,
    required this.postText,
    this.postImage,
  });

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  late TextEditingController _postTextController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _postTextController = TextEditingController(text: widget.postText);
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    String? imageUrl = widget.postImage;
    if (_imageFile != null) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('$imageName.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'text': _postTextController.text,
      'postImage': imageUrl,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _postTextController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter your updated post text...',
              ),
            ),
            const SizedBox(height: 16),
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    height: 200,
                  )
                : FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: widget.postImage ?? '',
                    height: 200,
                    width: 100,
                  ),
            const SizedBox(height: 16),
            const SizedBox(height: 16.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(10.0),
                    ),
                  ),
                  onPressed: () => _getImage(ImageSource.camera),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(116, 158, 158, 158),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(10.0),
                    ),
                  ),
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.photo,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Photos/Gallery",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 164, 200, 169),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
