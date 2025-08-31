import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('fittracker_user');
      if (userJson != null) {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user from storage: $e');
      }
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fittracker_user', jsonEncode(user.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user to storage: $e');
      }
    }
  }

  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fittracker_user');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user from storage: $e');
      }
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      _user = user;
      await _saveUserToStorage(user);
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _apiService.register(
        username: username,
        email: email,
        password: password,
        name: name,
      );
      _user = user;
      await _saveUserToStorage(user);
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUser(_user!.id, updates);
      _user = updatedUser;
      await _saveUserToStorage(updatedUser);
      notifyListeners();
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _clearUserFromStorage();
    notifyListeners();
  }
}
