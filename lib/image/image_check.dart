import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_face_match/image/result.dart';
import 'package:flutter_face_match/image/take_photo_screen.dart';
import 'package:flutter_face_match/success.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FaceComparisonScreen extends StatefulWidget {
  final File? imageCMND;
  final Map<String, dynamic>? cmndData;

  const FaceComparisonScreen({super.key, this.imageCMND, this.cmndData});

  @override
  _FaceComparisonScreenState createState() => _FaceComparisonScreenState();
}

class _FaceComparisonScreenState extends State<FaceComparisonScreen> {
  File? _image1;
  File? _image2;

  // Chọn ảnh từ thư viện
  Future<void> _pickImageFromGallery(int imageNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  // Chụp ảnh từ camera
  Future<void> _pickImageFromCamera(int imageNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  // Gửi yêu cầu so sánh khuôn mặt với API
  Future<void> _checkFace() async {
    if (widget.imageCMND == null || _image2 == null) {
      print("Vui lòng chụp hoặc chọn cả hai ảnh");
      return;
    }

    try {
      final uri = Uri.parse('https://api.fpt.ai/dmp/checkface/v1');
      final request = http.MultipartRequest('POST', uri)
        ..headers['api-key'] = 'PoysBbUQ3dabdBKuLiWbHn9W5Lsl2LVM';

      request.files.add(await http.MultipartFile.fromPath(
        'file[]',
        widget.imageCMND!.path,
        filename: 'image1.jpg',
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'file[]',
        _image2!.path,
        filename: 'image2.jpg',
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = jsonDecode(responseData);

        // Chuyển đến màn hình hiển thị kết quả
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaceComparisonResultScreen(
              apiResult: result,
              cmndData: widget.cmndData ?? {}, // Truyền dữ liệu CMND nếu có
              imageCMND: widget.imageCMND!,
            ),
          ),
        );
      } else {
        print("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi gửi yêu cầu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực khuôn mặt'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị ảnh chụp từ CMNDRecognitionScreen
              if (widget.imageCMND != null)
                Column(
                  children: [
                    const Text(
                      'Ảnh CMND đã chụp:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Image.file(widget.imageCMND!, height: 200, width: 200),
                    const SizedBox(height: 16),
                  ],
                ),

              // Hiển thị ảnh chọn hoặc chụp bản thân
              if (_image2 != null)
                Column(
                  children: [
                    const Text(
                      'Ảnh bản thân:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Image.file(_image2!, height: 200, width: 200),
                  ],
                ),

              const SizedBox(height: 16),

              // Nút chụp ảnh bản thân
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceCaptureScreen(
                        onImageCaptured: (imagePath) {
                          setState(() {
                            _image2 =
                                File(imagePath); // Gán ảnh chụp vào _image2
                          });
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Chụp ảnh bản thân'),
              ),

              // Nút kiểm tra khuôn mặt
              ElevatedButton(
                onPressed: _checkFace,
                child: const Text('Xác thực'),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
