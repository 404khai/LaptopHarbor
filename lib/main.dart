import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: const LaptopHarborApp(),
    ),
  );
}

class LaptopHarborApp extends StatefulWidget {
  const LaptopHarborApp({super.key});

  @override
  State<LaptopHarborApp> createState() => _LaptopHarborAppState();
}

class _LaptopHarborAppState extends State<LaptopHarborApp> {
  bool _initialized = false;

  Future<void> _upsertToken(String uid, String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set(<String, dynamic>{
          'token': token,
          'platform': 'android',
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _maybeSyncFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = userDoc.data() ?? const <String, dynamic>{};
    final enabled = data['appNotificationsEnabled'];
    if (enabled == false) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) return;
    await _upsertToken(user.uid, token.trim());
  }

  @override
  void initState() {
    super.initState();
    if (_initialized) return;
    _initialized = true;

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;
      await _maybeSyncFcmToken();
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final current = FirebaseAuth.instance.currentUser;
      if (current == null) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid)
          .get();
      final data = userDoc.data() ?? const <String, dynamic>{};
      final enabled = data['appNotificationsEnabled'];
      if (enabled == false) return;
      await _upsertToken(current.uid, token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaptopHarbor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
