import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String postText;
  final List<String>? postImages;

  const EditPostScreen({
    super.key,
    required this.postId,
    required this.postText,
    this.postImages,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _postTextController;
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _postTextController = TextEditingController(text: widget.postText);
    if (widget.postImages != null) {
      _imageUrls.addAll(widget.postImages!);
    }
  }

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    List<String> updatedImageUrls = List.from(_imageUrls);

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'text': _postTextController.text,
      'postImages': updatedImageUrls,
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
      String imageUrl = await _uploadImage(File(pickedFile.path));
      setState(() {
        _imageUrls.add(imageUrl);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('$imageName.jpg');
    await ref.putFile(imageFile);
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> _deleteImage(int index) async {
    setState(() {
      _imageUrls.removeAt(index);
    });
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
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteImage(index),
                      ),
                    ],
                  );
                },
              ),
            ),
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
