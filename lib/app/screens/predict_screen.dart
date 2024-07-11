import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageUploader {
  static Future<String?> uploadImage(File imageFile) async {
    var url = 'http://10.0.2.2:9000/upload';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = await response.stream.bytesToString();
        var prediction = jsonDecode(jsonResponse)['prediction'];
        return prediction;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  File? _imageFile;
  String? _prediction;
  bool _isLoading = false;

  Future<void> pickImageAndUpload(
      BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _prediction = null;
        _isLoading = true;
      });

      String? prediction = await ImageUploader.uploadImage(_imageFile!);
      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No image selected.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Prediction',
          style: GoogleFonts.rubik(
            textStyle: const TextStyle(
              fontSize: 35,
              color: Color.fromARGB(255, 26, 115, 44),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: MediaQuery.sizeOf(context).height * 0.5,
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickImageAndUpload(context, ImageSource.gallery);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.blue,
                        size: 23,
                      ),
                      SizedBox(width: 10),
                      Text('Gallery/Photos',
                          style: TextStyle(color: Colors.black, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    pickImageAndUpload(context, ImageSource.camera);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Text('Camera',
                          style: TextStyle(color: Colors.black, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(
                color: Color.fromARGB(255, 26, 115, 44),
              )
            else if (_prediction != null)
              Column(
                children: [
                  Text(
                    '$_prediction',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Color.fromARGB(255, 26, 115, 44),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
