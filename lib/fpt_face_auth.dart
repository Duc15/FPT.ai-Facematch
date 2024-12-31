import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FptFaceAuth {
  static const String _apiKey = 'PoysBbUQ3dabdBKuLiWbHn9W5Lsl2LVM';
  static const String _apiUrl = 'https://api.fpt.ai/dmp/checkface/v1';

  /// Gửi hai ảnh để so khớp khuôn mặt
  static Future<Map<String, dynamic>> compareFaces(
      File image1, File image2) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..headers['api-key'] = _apiKey
        ..files.add(await http.MultipartFile.fromPath('image1', image1.path))
        ..files.add(await http.MultipartFile.fromPath('image2', image2.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        return jsonDecode(responseData.body);
      } else {
        return {
          'error':
              'Failed to compare faces. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
