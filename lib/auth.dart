import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'fpt_face_auth.dart';

class FaceAuthScreen extends StatefulWidget {
  @override
  _FaceAuthScreenState createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> {
  File? _image1;
  File? _image2;
  String _result = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int imageIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        if (imageIndex == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _compareFaces() async {
    if (_image1 != null && _image2 != null) {
      final result = await FptFaceAuth.compareFaces(_image1!, _image2!);
      setState(() {
        _result = result.toString();
      });
    } else {
      setState(() {
        _result = 'Please select both images';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Authentication')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(1),
                child: Text('Pick Image 1'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(2),
                child: Text('Pick Image 2'),
              ),
            ],
          ),
          if (_image1 != null) Image.file(_image1!, height: 100),
          if (_image2 != null) Image.file(_image2!, height: 100),
          ElevatedButton(
            onPressed: _compareFaces,
            child: Text('Compare Faces'),
          ),
          Text(_result),
        ],
      ),
    );
  }
}
