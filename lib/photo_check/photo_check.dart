import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_face_match/image/take_photo_screen.dart';
import 'package:flutter_face_match/success.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PhotoCheck extends StatefulWidget {
  const PhotoCheck({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FaceComparisonScreenState createState() => _FaceComparisonScreenState();
}

class _FaceComparisonScreenState extends State<PhotoCheck> {
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
    if (_image1 == null || _image2 == null) {
      print("Please select or capture both images");
      return;
    }

    try {
      final uri = Uri.parse('https://api.fpt.ai/dmp/checkface/v1');
      final request = http.MultipartRequest('POST', uri)
        ..headers['api-key'] = 'PoysBbUQ3dabdBKuLiWbHn9W5Lsl2LVM';

      // Thêm ảnh vào request
      request.files.add(await http.MultipartFile.fromPath(
        'file[]', _image1!.path,
        filename: 'image1.jpg', // Đảm bảo rằng bạn có thêm tên tệp
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'file[]',
        _image2!.path,
        filename: 'image2.jpg',
      ));

      // Gửi yêu cầu
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = jsonDecode(responseData);

        print(result); // In ra kết quả để kiểm tra

        // Lấy dữ liệu trả về
        double similarity = result['data']['similarity'];
        bool isMatch = result['data']['isMatch'];
        bool isBothImgIDCard = result['data']['isBothImgIDCard'];

        String message = isMatch
            ? "Mặt trùng khớp tới:  ${similarity.toStringAsFixed(2)}%"
            : "Mặt không trùng khớp. Độ trùng khớp: ${similarity.toStringAsFixed(2)}%";

        if (isBothImgIDCard) {
          message += "\nBoth images are ID cards.";
        }

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(isMatch ? "Xác thực thành công" : "Xác thực thất bại"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuccessScreen(
                        similarity: similarity.toString(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        print("Failed to compare faces, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during face comparison: $e");
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
              // Hiển thị ảnh chọn từ thư viện
              if (_image1 != null) Image.file(_image1!),
              if (_image2 != null) Image.file(_image2!),

              // Nút chọn ảnh từ thư viện
              ElevatedButton(
                onPressed: () => _pickImageFromGallery(1),
                child: const Text('Chọn ảnh CMND'),
              ),
              ElevatedButton(
                onPressed: () => _pickImageFromGallery(2),
                child: const Text('Chọn ảnh bản thân'),
              ),

              // Nút chụp ảnh từ camera
              ElevatedButton(
                onPressed: () => _pickImageFromCamera(1),
                child: const Text('Chụp ảnh CMND'),
              ),
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
