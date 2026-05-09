import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _verificationId;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> sendOtp(String phoneNumber, Function(String) onCodeSent, Function(String) onError) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
          onCodeSent(verificationId);
        },
        verificationFailed: (e) {
          _isLoading = false;
          notifyListeners();
          onError(e.message ?? 'Verification failed');
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  Future<void> verifyOtp(String smsCode, Function() onSuccess, Function(String) onError) async {
    if (_verificationId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithOTP(verificationId: _verificationId!, smsCode: smsCode);
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
