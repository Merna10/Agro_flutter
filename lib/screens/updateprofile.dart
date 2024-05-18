import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:transparent_image/transparent_image.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String? userImage;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    this.userImage,
  });

  @override
  State<EditProfileScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameTextController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _usernameTextController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    String? imageUrl = widget.userImage;
    if (_imageFile != null) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('image_url')
          .child('$imageName.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        documentSnapshot.reference.update({
          'username': _usernameTextController.text,
          'userImage': imageUrl,
        });
      }
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({
          'username': _usernameTextController.text,
          'userImage': imageUrl,
        });
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {});
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
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Edit User Name:",
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Georgia',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              TextField(
                controller: _usernameTextController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter your updated name ...',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Edit Profile picture ",
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Georgia',
                  color: Theme.of(context).colorScheme.secondary,
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
                      image: widget.userImage ?? '',
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
      ),
    );
  }
}
