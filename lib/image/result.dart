import 'dart:io';
import 'package:flutter/material.dart';

class FaceComparisonResultScreen extends StatelessWidget {
  final Map<String, dynamic> apiResult;
  final Map<String, dynamic> cmndData;
  final File imageCMND;

  const FaceComparisonResultScreen({
    super.key,
    required this.apiResult,
    required this.cmndData,
    required this.imageCMND,
  });

  @override
  Widget build(BuildContext context) {
    final similarity = apiResult['data']['similarity'];
    final isMatch = apiResult['data']['isMatch'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả xác thực'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin từ CMND:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Họ tên: ${cmndData['name'] ?? 'Không có dữ liệu'}'),
            Text('Ngày sinh: ${cmndData['dob'] ?? 'Không có dữ liệu'}'),
            Text('Số CMND: ${cmndData['id'] ?? 'Không có dữ liệu'}'),
            Text('Giới tính: ${cmndData['sex']}'),
            Text('Quốc gia: ${cmndData['nationality']}'),
            const SizedBox(height: 16),
            Image.file(imageCMND, height: 200, width: double.infinity),
            const SizedBox(height: 16),
            const Text(
              'Kết quả xác thực khuôn mặt:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Độ tương đồng: ${similarity.toStringAsFixed(2)}%'),
            Text(isMatch ? 'Kết quả: Trùng khớp' : 'Kết quả: Không trùng khớp'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
