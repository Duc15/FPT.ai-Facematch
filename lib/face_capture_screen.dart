import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class FaceCaptureScreen extends StatefulWidget {
  final Function(String imagePath) onImageCaptured;

  FaceCaptureScreen({required this.onImageCaptured});

  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _cameraController;
  bool _isDetectingFace = false;
  int? _countdown;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    await _cameraController?.initialize();

    if (mounted) {
      setState(() {});
    }

    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 3; // Bắt đầu đếm ngược từ 3 giây
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown! > 0) {
          _countdown = _countdown! - 1;
        } else {
          timer.cancel();
          _captureImage(); // Chụp ảnh khi kết thúc đếm ngược
        }
      });
    });
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final image = await _cameraController!.takePicture();
        widget.onImageCaptured(image.path);
        Navigator.pop(context);
      } catch (e) {
        print("Error capturing image: $e");
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Capture'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Hiển thị Camera
          CameraPreview(_cameraController!),
          // Hiệu ứng mờ xung quanh
          _buildBlurEffect(),
          // Khung viền elip
          _buildEllipseBorder(),
          // Nội dung đếm ngược
          if (_countdown != null)
            Center(
              child: Text(
                _countdown! > 0 ? '$_countdown' : "Chụp ảnh!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Nút Hủy
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Hủy', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurEffect() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Định nghĩa kích thước hình bầu dục (ellipse)
        final ellipseWidth =
            width * 0.6; // Tăng kích thước chiều rộng lên 60% màn hình
        final ellipseHeight =
            height * 0.4; // Tăng kích thước chiều cao lên 40% màn hình
        final centerY =
            height * 0.4; // Đặt hình bầu dục ở 40% chiều cao từ trên xuống

        return ClipPath(
          clipper:
              FaceShapeClipper(width / 2, centerY, ellipseWidth, ellipseHeight),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEllipseBorder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Định nghĩa kích thước hình bầu dục (ellipse)
        final ellipseWidth = width * 0.6;
        final ellipseHeight = height * 0.4;
        final centerY = height * 0.4;

        return Positioned(
          top: centerY - ellipseHeight / 2,
          left: width / 2 - ellipseWidth / 2,
          child: Container(
            width: ellipseWidth,
            height: ellipseHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(ellipseHeight / 2),
            ),
          ),
        );
      },
    );
  }
}

class FaceShapeClipper extends CustomClipper<Path> {
  final double centerX;
  final double centerY;
  final double width;
  final double height;

  FaceShapeClipper(this.centerX, this.centerY, this.width, this.height);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: width,
        height: height,
      ))
      ..fillType = PathFillType.evenOdd; // Giữ lại phần bên ngoài hình bầu dục
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
