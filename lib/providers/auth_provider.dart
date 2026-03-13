import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userProfileSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _userProfileSubscription?.cancel();
      _userProfile = null;

      if (user != null) {
        _userProfileSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
              _userProfile = doc.data();
              notifyListeners();
            });
      }
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        final displayName = '$firstName $lastName'.trim();
        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }

        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'displayName': displayName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
