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

  String? _userProfileError;
  String? get userProfileError => _userProfileError;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userProfileSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _userProfileSubscription?.cancel();
      _userProfile = null;
      _userProfileError = null;

      if (user != null) {
        _userProfileSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen(
              (doc) {
                _userProfile = doc.data();
                _userProfileError = null;
                notifyListeners();
              },
              onError: (Object error, StackTrace stackTrace) {
                if (error is FirebaseException &&
                    error.code == 'permission-denied') {
                  _userProfileError =
                      'Missing or insufficient Firestore permissions for user profile.';
                } else {
                  _userProfileError = 'Failed to load user profile.';
                }
                _userProfile = null;
                _userProfileSubscription?.cancel();
                _userProfileSubscription = null;
                notifyListeners();
              },
            );
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

        try {
          await _firestore.collection('users').doc(user.uid).set({
            'firstName': firstName,
            'lastName': lastName,
            'displayName': displayName,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'user',
          });
          _userProfileError = null;
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
            _userProfileError =
                'Account created, but Firestore permissions prevented saving the profile.';
          } else {
            _userProfileError = 'Account created, but profile save failed.';
          }
        }
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
    _userProfileSubscription?.cancel();
    _userProfileSubscription = null;
    _userProfile = null;
    _userProfileError = null;
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String displayName,
    String? phone,
    String? bio,
    String? photoUrl,
    String? phoneIso,
    String? phoneNational,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 'Not signed in';

    try {
      _isLoading = true;
      notifyListeners();

      final normalizedDisplayName = displayName.trim();
      if (normalizedDisplayName.isNotEmpty) {
        await currentUser.updateDisplayName(normalizedDisplayName);
      }
      final normalizedPhotoUrl = photoUrl?.trim();
      if (normalizedPhotoUrl != null && normalizedPhotoUrl.isNotEmpty) {
        await currentUser.updatePhotoURL(normalizedPhotoUrl);
      }

      final parts = normalizedDisplayName
          .split(RegExp(r'\s+'))
          .where((p) => p.trim().isNotEmpty)
          .toList();
      final firstName = parts.isNotEmpty ? parts.first : null;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;

      await _firestore.collection('users').doc(currentUser.uid).set({
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (normalizedDisplayName.isNotEmpty)
          'displayName': normalizedDisplayName,
        if (currentUser.email != null) 'email': currentUser.email,
        if (phone != null) 'phone': phone.trim(),
        if (bio != null) 'bio': bio.trim(),
        if (normalizedPhotoUrl != null && normalizedPhotoUrl.isNotEmpty)
          'photoUrl': normalizedPhotoUrl,
        if (phoneIso != null && phoneIso.trim().isNotEmpty)
          'phoneIso': phoneIso.trim(),
        if (phoneNational != null && phoneNational.trim().isNotEmpty)
          'phoneNational': phoneNational.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _userProfileError = null;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'permission-denied') {
        return 'Missing or insufficient Firestore permissions to save profile.';
      }
      return e.message ?? 'Failed to save profile';
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to save profile';
    }
  }
}
