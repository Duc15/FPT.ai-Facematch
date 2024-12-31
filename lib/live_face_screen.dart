import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LiveFaceScreen extends StatefulWidget {
  @override
  _LiveFaceScreenState createState() => _LiveFaceScreenState();
}

class _LiveFaceScreenState extends State<LiveFaceScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Lấy danh sách camera trên thiết bị
      _cameras = await availableCameras();
      // Sử dụng camera phía trước
      _cameraController = CameraController(
        _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Face Verification')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isCameraInitialized && _cameraController != null)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else
            Center(
                child:
                    CircularProgressIndicator()), // Hiển thị trạng thái khi camera chưa sẵn sàng

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_cameraController != null) {
                // Chụp ảnh khuôn mặt hiện tại
                final image = await _cameraController!.takePicture();

                // Chuyển sang màn hình kết quả và gửi ảnh chụp đi
                Navigator.pushNamed(
                  context,
                  '/result',
                  arguments: {
                    'liveImagePath': image.path,
                    'isMatched': true
                  }, // isMatched là giả lập
                );
              }
            },
            child: Text('Capture and Verify'),
          ),
        ],
      ),
    );
  }
}
