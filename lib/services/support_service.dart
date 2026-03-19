import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SupportService {
  static String _supportFunctionUrl() {
    final fromEnv = dotenv.env['SUPPORT_FUNCTION_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return '';
  }

  static Future<void> sendSupportEmail({
    required String title,
    required String subject,
    required String message,
    required String ticketId,
  }) async {
    final url = _supportFunctionUrl();
    if (url.isEmpty) throw Exception('Missing SUPPORT_FUNCTION_URL');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');
    final token = await user.getIdToken();

    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'subject': subject,
        'message': '$message\n\nTicket: $ticketId',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Support email failed');
    }
  }

  static Future<String> submitSupportTicket({
    required String title,
    required String subject,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final profile = userDoc.data();

    final firstName = (profile?['firstName'] ?? profile?['firstname'] ?? '')
        .toString()
        .trim();
    final lastName = (profile?['lastName'] ?? profile?['lastname'] ?? '')
        .toString()
        .trim();
    final displayName = (profile?['displayName'] ?? user.displayName ?? '')
        .toString()
        .trim();
    final name =
        ([
          firstName,
          lastName,
        ].where((e) => e.isNotEmpty).join(' ')).trim().isNotEmpty
        ? ([firstName, lastName].where((e) => e.isNotEmpty).join(' ')).trim()
        : (displayName.isNotEmpty ? displayName : 'Anonymous');

    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('supportTickets');

    final docRef = await col.add(<String, dynamic>{
      'title': title.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email,
      'userId': user.uid,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await sendSupportEmail(
      title: title.trim(),
      subject: subject.trim(),
      message: message.trim(),
      ticketId: docRef.id,
    );

    return docRef.id;
  }
}
