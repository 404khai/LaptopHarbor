import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportService {
  static String _supportToEmail() {
    final fromEnv = dotenv.env['SUPPORT_TO_EMAIL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return '';
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

    return docRef.id;
  }

  static Future<void> openEmailApp({
    required String title,
    required String subject,
    required String message,
    String? ticketId,
  }) async {
    final toEmail = _supportToEmail();
    if (toEmail.isEmpty) throw Exception('Missing SUPPORT_TO_EMAIL');

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim();
    final name = (user?.displayName ?? '').trim();

    final bodyParts = <String>[
      if (name.isNotEmpty) 'Name: $name',
      if (email != null && email.isNotEmpty) 'Email: $email',
      if (ticketId != null && ticketId.isNotEmpty) 'Ticket: $ticketId',
      '',
      message,
    ];

    final uri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: <String, String>{
        'subject': '[$title] $subject',
        'body': bodyParts.join('\n'),
      },
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('Failed to open email app');
  }
}
