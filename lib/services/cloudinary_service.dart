import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static String? _cloudName() => dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim();
  static String? _uploadPreset() =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim();
  static String? _folder() => dotenv.env['CLOUDINARY_FOLDER']?.trim();

  static Future<String> uploadImageBytes({
    required List<int> bytes,
    required String filename,
  }) async {
    final cloudName = _cloudName();
    final uploadPreset = _uploadPreset();
    if (cloudName == null ||
        cloudName.isEmpty ||
        uploadPreset == null ||
        uploadPreset.isEmpty) {
      throw Exception('Missing Cloudinary config');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    final folder = _folder();
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await request.send();
    final responseBody = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Cloudinary upload failed');
    }

    final decoded = jsonDecode(responseBody);
    final url = (decoded['secure_url'] ?? decoded['url'] ?? '').toString();
    if (url.isEmpty) throw Exception('Cloudinary upload failed');
    return url;
  }
}

