import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditCommentScreen extends StatefulWidget {
  final String postId;
  final String commentId;
  final String commentText;
  final List<String>? commentImage;

  const EditCommentScreen({
    super.key,
    required this.postId,
    required this.commentId,
    required this.commentText,
    this.commentImage,
  });

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  late TextEditingController _commentTextController;
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _commentTextController = TextEditingController(text: widget.commentText);
    if (widget.commentImage != null) {
      _imageUrls.addAll(widget.commentImage!);
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  Future<void> _updateComment() async {
    List<String> updatedImageUrls = List.from(_imageUrls);

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .update({
      'comment': _commentTextController.text,
      'postImages': updatedImageUrls,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commet updated successfully'),
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
        title: const Text('Edit Comment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateComment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _commentTextController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter your updated Commet text...',
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
                          color: Color.fromARGB(255, 155, 152, 152),
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
                          color: Color.fromARGB(255, 155, 152, 152),
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

class EditRepliesScreen extends StatefulWidget {
  final String postId;
  final String commentId;
  final String replyId;
  final String commentText;
  final List<String>? commentImage;

  const EditRepliesScreen({
    super.key,
    required this.postId,
    required this.commentId,
    required this.replyId,
    required this.commentText,
    this.commentImage,
  });

  @override
  State<EditRepliesScreen> createState() => _EditRepliesScreenState();
}

class _EditRepliesScreenState extends State<EditRepliesScreen> {
  late TextEditingController _commentTextController;
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _commentTextController = TextEditingController(text: widget.commentText);
    if (widget.commentImage != null) {
      _imageUrls.addAll(widget.commentImage!);
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  Future<void> _updateComment() async {
    List<String> updatedImageUrls = List.from(_imageUrls);

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('replies')
        .doc(widget.replyId)
        .update({
      'text': _commentTextController.text,
      'repliesImages': updatedImageUrls,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment updated successfully'),
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
        title: const Text('Edit Comment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateComment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _commentTextController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter your updated Comment text...',
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
                          color: Color.fromARGB(255, 155, 152, 152),
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
                          color: Color.fromARGB(255, 155, 152, 152),
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
