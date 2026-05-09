import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    _profile = await _firestoreService.getProfile(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? photoUrl = profile.photoUrl;
      if (imageFile != null) {
        photoUrl = await _storageService.uploadProfileImage(profile.id, imageFile);
      }
      
      final updatedProfile = profile.copyWith(photoUrl: photoUrl);
      await _firestoreService.saveProfile(updatedProfile);
      _profile = updatedProfile;
    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateLocalProfile(UserProfile updatedProfile) {
    _profile = updatedProfile;
    notifyListeners();
  }
}
