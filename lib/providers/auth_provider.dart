import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  late StreamSubscription<User?> _authSubscription;

  AuthProvider() {
    _user = _authService.currentUser;
    if (_user != null) {
      _syncUserProfileToFirestore(_user!);
    }
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      if (user != null) {
        _syncUserProfileToFirestore(user);
      }
      notifyListeners();
    });
  }

  String? _phoneNumber;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get displayName =>
      _user?.displayName ?? _user?.email?.split('@')[0] ?? 'Floral Member';
  String get email => _user?.email ?? 'member@bloomandribbon.com';
  String? get photoURL => _user?.photoURL;
  String get phoneNumber => _phoneNumber ?? _user?.phoneNumber ?? '+66 81 234 5678';

  String get initials {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      final parts = _user!.displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    if (_user?.email != null && _user!.email!.isNotEmpty) {
      return _user!.email![0].toUpperCase();
    }
    return 'BR';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Auto-sync user document into Firestore /users/{userId}
  Future<void> _syncUserProfileToFirestore(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['phoneNumber'] != null) {
          _phoneNumber = data['phoneNumber'] as String?;
        }
      }
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@')[0],
        'photoURL': user.photoURL,
        'phoneNumber': _phoneNumber,
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing user profile to Firestore: $e');
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String phoneNumber,
    String? photoURL,
  }) async {
    _setLoading(true);
    try {
      if (_user != null) {
        await _user!.updateDisplayName(displayName.trim());
        if (photoURL != null && photoURL.isNotEmpty) {
          await _user!.updatePhotoURL(photoURL);
        }
        await _firestore.collection('users').doc(_user!.uid).set({
          'displayName': displayName.trim(),
          'phoneNumber': phoneNumber.trim(),
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _phoneNumber = phoneNumber.trim();
        _user = _authService.currentUser;
      }
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<String?> uploadAvatarBytes(dynamic bytes, String filename) async {
    if (_user == null) return null;
    _setLoading(true);
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(_user!.uid)
          .child('avatars')
          .child('${DateTime.now().millisecondsSinceEpoch}_$filename');

      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      await updateProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoURL: downloadUrl,
      );
      _setLoading(false);
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase storage avatar upload error: $e');
      _errorMessage = 'Storage upload error: $e';
      _setLoading(false);
      return null;
    }
  }

  // Sign In with Email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithEmail(email: email, password: password);
      if (credential.user != null) {
        await _syncUserProfileToFirestore(credential.user!);
      }
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Register with Email
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (credential.user != null) {
        await _syncUserProfileToFirestore(credential.user!);
      }
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      if (_authService.currentUser != null) {
        await _syncUserProfileToFirestore(_authService.currentUser!);
      }
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
