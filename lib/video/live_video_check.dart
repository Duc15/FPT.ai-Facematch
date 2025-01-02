import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Thêm thư viện này để sử dụng Timer
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_face_match/main.dart';
import 'package:flutter_face_match/success.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LiveVideoCheck extends StatelessWidget {
  final List<CameraDescription> cameras;
  LiveVideoCheck({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Liveness Check',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FaceVerificationScreen(cameras: cameras),
    );
  }
}

class FaceVerificationScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceVerificationScreen({super.key, required this.cameras});

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _cameraController;
  File? _selectedImage;
  File? _recordedVideo;
  bool _isLoading = false;
  int _timerSeconds = 5; // Số giây đếm ngược
  Timer? _timer; // Để điều khiển bộ đếm giây

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    print("Đang khởi tạo camera...");
    _cameraController = CameraController(
      widget.cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );

    await _cameraController?.initialize();
    print("Camera đã được khởi tạo.");
    setState(() {});
  }

  Future<void> _pickImage() async {
    print("Mở trình chọn ảnh...");
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
      print("Đã chọn ảnh: ${_selectedImage!.path}");
    } else {
      print("Người dùng không chọn ảnh.");
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController?.value.isInitialized ?? false) {
      print("Bắt đầu quay video...");
      final directory = await getTemporaryDirectory();
      final videoPath = '${directory.path}/video.mp4';

      await _cameraController?.startVideoRecording();
      print("Đang quay video: $videoPath");

      _startTimer(); // Bắt đầu bộ đếm giây khi quay video

      await Future.delayed(Duration(seconds: 5)); // Quay video trong 5 giây
      final videoFile = await _cameraController?.stopVideoRecording();
      if (videoFile != null) {
        setState(() {
          _recordedVideo = File(videoFile.path);
        });
        print("Video đã được lưu tại: ${_recordedVideo!.path}");
      }
    }
  }

  void _startTimer() {
    // Bắt đầu bộ đếm giây
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel(); // Dừng bộ đếm khi hết thời gian
      }
    });
  }

  Future<void> _sendToApi() async {
    if (_recordedVideo != null && _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.fpt.ai/dmp/liveness/v3'),
      );

      request.headers['api-key'] = 'PoysBbUQ3dabdBKuLiWbHn9W5Lsl2LVM';
      request.files.add(
          await http.MultipartFile.fromPath('video', _recordedVideo!.path));
      request.files
          .add(await http.MultipartFile.fromPath('cmnd', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print("Kết quả API: $responseData");

        // Parse JSON và xử lý kết quả
        final result = jsonDecode(responseData);
        final isMatch = result['face_match']['isMatch'] == 'true';
        final similarity = result['face_match']['similarity'];
        final warning = result['liveness']['warning'];

        if (isMatch) {
          // Điều hướng tới màn hình Success
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(similarity: similarity),
            ),
          );
        } else {
          // Hiển thị lỗi nếu không khớp
          _showDialog(
            context,
            "Xác thực không thành công",
            "Khuôn mặt không khớp. Vui lòng thử lại.",
          );
        }
      } else {
        _showDialog(
          context,
          "Lỗi",
          "Không thể gửi dữ liệu. Vui lòng thử lại.",
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      _showDialog(
        context,
        "Thiếu dữ liệu",
        "Vui lòng chọn ảnh và quay video.",
      );
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel(); // Dừng bộ đếm khi dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Liveness Check"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Home(cameras: widget.cameras),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              if (_cameraController?.value.isInitialized ?? false)
                CameraPreview(_cameraController!),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Positioned(
                top: 150, // Đặt bộ đếm giây ở giữa màn hình
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '$_timerSeconds s',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Chọn ảnh đối chiếu"),
          ),
          ElevatedButton(
            onPressed: _startRecording,
            child: const Text("Quay video"),
          ),
          ElevatedButton(
            onPressed: _sendToApi,
            child: const Text("Đối chiếu khuôn mặt"),
          ),
          if (_selectedImage != null)
            Center(
              child: Card(
                child: Text(
                  "Đã chọn ảnh: ${_selectedImage!.path.split('/').last}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          if (_recordedVideo != null)
            Card(
              child: Center(
                // Add Center widget to center the text inside the card
                child: Text(
                  "Đã quay video: ${_recordedVideo!.path.split('/').last}",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign
                      .center, // This will center the text horizontally
                ),
              ),
            )
        ],
      ),
    );
  }
}
