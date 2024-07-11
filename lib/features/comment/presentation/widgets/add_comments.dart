import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/features/comment/data/model/comments.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddComments extends StatefulWidget {
  const AddComments({super.key, required this.postId, required this.userId});
  final String postId;
  final String userId;
  @override
  State<AddComments> createState() => _AddCommentsState();
}

class _AddCommentsState extends State<AddComments> {
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

        Comment newComment = Comment(
          userId: widget.userId,
          comment: commentText,
          createdAt: DateTime.now(),
          postImages: imageUrls,
        );
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add(newComment.toMap());
        _commentController.clear();

        setState(() {
          _images.clear();
        });
      } catch (e) {
        //
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        Text(value, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.07,
              ),
              ElevatedButton(
                onPressed: _addComment,
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
                child: const Text(
                  'Add Comment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
