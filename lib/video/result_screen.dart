import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isMatch;
  final double similarity;
  final bool isLive;

  ResultScreen({
    required this.isMatch,
    required this.similarity,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả kiểm tra'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isMatch ? Icons.check_circle : Icons.error,
              size: 100,
              color: isMatch ? Colors.green : Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              isMatch ? "Khuôn mặt trùng khớp!" : "Khuôn mặt không trùng khớp!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isMatch ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Độ giống nhau: ${similarity.toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLive ? Icons.verified : Icons.warning,
                  color: isLive ? Colors.green : Colors.red,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  isLive
                      ? "Người thật được xác nhận!"
                      : "Không phát hiện người thật!",
                  style: TextStyle(
                    fontSize: 18,
                    color: isLive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Quay lại"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
