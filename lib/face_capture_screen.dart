import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
      _countdown = 10; // Bắt đầu đếm ngược từ 3 giây
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
          // Vòng tròn với các thanh
          _buildCircleWithBars(),
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

  Widget _buildCircleWithBars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final centerX = width / 2;
        final centerY = height * 0.4;
        final radius = min(width, height) * 0.3;

        return Stack(
          children: [
            // Vòng tròn bên trong
            Positioned(
              top: centerY - radius,
              left: centerX - radius,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            // Các thanh dọc xung quanh
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                painter: BarsPainter(_countdown, radius),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BarsPainter extends CustomPainter {
  final int? countdown;
  final double radius;

  BarsPainter(this.countdown, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final totalBars = 300; // Tăng số lượng thanh lên 100
    final maxHeight = radius * 0.3; // Chiều cao tối đa của thanh
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Số lượng thanh đã "kích hoạt" dựa trên thời gian đếm ngược
    final activatedBars =
        countdown != null ? ((totalBars * (10 - countdown!)) / 10).ceil() : 0;

    for (int i = 0; i < totalBars; i++) {
      // Tính toán góc cho mỗi thanh, bắt đầu từ góc -π/2 (12 giờ)
      final angle = -pi / 2 + 2 * pi * i / totalBars;
      final startX = center.dx + radius * cos(angle);
      final startY = center.dy + radius * sin(angle);

      // Chiều cao của thanh tăng dần nếu nó đã "kích hoạt"
      final barHeight = i < activatedBars ? maxHeight : 0;

      final endX = center.dx + (radius + barHeight) * cos(angle);
      final endY = center.dy + (radius + barHeight) * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
