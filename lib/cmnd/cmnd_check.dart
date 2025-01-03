import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_match/cmnd/cmnd_detail.dart';
import 'package:http/http.dart' as http;

class CMNDRecognitionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CMNDRecognitionScreen({required this.cameras});

  @override
  _CMNDRecognitionScreenState createState() => _CMNDRecognitionScreenState();
}

class _CMNDRecognitionScreenState extends State<CMNDRecognitionScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  File? _capturedImage;
  String? _apiResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );

    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    });
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      setState(() => _capturedImage = File(image.path));
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _scanCMND() async {
    if (_capturedImage == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.fpt.ai/vision/idr/vnm'),
    );
    request.headers['api-key'] = 'PoysBbUQ3dabdBKuLiWbHn9W5Lsl2LVM';
    request.files
        .add(await http.MultipartFile.fromPath('image', _capturedImage!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['errorCode'] == 0 && jsonResponse['data'] != null) {
          // Lấy thông tin từ response
          final Map<String, dynamic> cmndData = jsonResponse['data'][0];

          // Chuyển đến màn hình hiển thị thông tin
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CMNDDetailsScreen(cmndData: cmndData),
            ),
          );
        } else {
          setState(() => _apiResult = 'Không tìm thấy dữ liệu hợp lệ.');
        }
      } else {
        setState(() => _apiResult = 'Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _apiResult = 'Lỗi kết nối: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CMND Recognition'),
      ),
      body: Column(
        children: [
          if (_isCameraInitialized)
            AspectRatio(
              aspectRatio: _cameraController.value.aspectRatio,
              child: CameraPreview(_cameraController),
            )
          else
            Center(child: CircularProgressIndicator()),
          SizedBox(height: 16),
          if (_capturedImage != null)
            Image.file(
              _capturedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Chụp Ảnh'),
              ),
              // Thêm nút "Quét CMND" để chuyển thông tin sang màn hình mới
              ElevatedButton(
                onPressed: _scanCMND,
                child: Text('Quét CMND'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_apiResult != null)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'API Result:\n$_apiResult',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
