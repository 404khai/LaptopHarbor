import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SupportService {
  static String _functionUrl() {
    final fromEnv = dotenv.env['SUPPORT_FUNCTION_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return 'https://us-central1-laptopharbor-94baa.cloudfunctions.net/sendSupportEmail';
  }

  static Future<void> submitSupportMessage({
    required String title,
    required String subject,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not signed in');
    }

    final res = await http.post(
      Uri.parse(_functionUrl()),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'subject': subject,
        'message': message,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Support submit failed');
    }
  }
}

