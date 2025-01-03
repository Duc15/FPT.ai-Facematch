import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_match/cmnd/cmnd_check.dart';
import 'package:flutter_face_match/image/image_check.dart'; // Thư viện so sánh qua ảnh
import 'package:flutter_face_match/photo_check/photo_check.dart';
import 'package:flutter_face_match/video/live_video_check.dart'; // Thư viện kiểm tra video trực tiếp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras(); // Lấy danh sách camera từ thiết bị
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Comparison',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(cameras: cameras),
    );
  }
}

class Home extends StatelessWidget {
  final List<CameraDescription> cameras;

  Home({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Comparison'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Chuyển đến màn hình so sánh khuôn mặt qua ảnh
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhotoCheck()),
                );
              },
              child: Text('So sánh khuôn mặt qua ảnh'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Chuyển đến màn hình kiểm tra video trực tiếp
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LiveVideoCheck(cameras: cameras)),
                );
              },
              child: Text('So sánh khuôn mặt qua video'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Chuyển đến màn hình kiểm tra video trực tiếp
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CMNDRecognitionScreen(cameras: cameras)),
                );
              },
              child: Text('Sinh trắc học'),
            ),
          ],
        ),
      ),
    );
  }
}
