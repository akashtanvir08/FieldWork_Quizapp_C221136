import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _keyCurrentUser = 'current_user_username';
  static const String _prefixUser = 'user_';

  // Private constructor
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  // Initialize helper (optional, SharedPreferences is loaded async)
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Signup
  Future<bool> signUpUser(String name, String username, String password) async {
    final prefs = await _prefs;
    final userKey = '$_prefixUser$username';

    // Check if user already exists
    if (prefs.containsKey(userKey)) {
      return false; // User already exists
    }

    final newUser = User(
      username: username,
      name: name,
      password: password,
      highestScores: {},
      lastScores: {},
      lastPassStatus: {},
    );

    await prefs.setString(userKey, newUser.toJson());
    return true;
  }

  // Login
  Future<User?> loginUser(String username, String password) async {
    final prefs = await _prefs;
    final userKey = '$_prefixUser$username';

    if (!prefs.containsKey(userKey)) {
      return null; // User not found
    }

    final userJson = prefs.getString(userKey);
    if (userJson == null) return null;

    final user = User.fromJson(userJson);
    if (user.password == password) {
      // Save current session
      await prefs.setString(_keyCurrentUser, username);
      return user;
    }

    return null; // Password mismatch
  }

  // Logout
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_keyCurrentUser);
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final currentUsername = prefs.getString(_keyCurrentUser);
    if (currentUsername == null) return null;

    final userKey = '$_prefixUser$currentUsername';
    final userJson = prefs.getString(userKey);
    if (userJson == null) return null;

    return User.fromJson(userJson);
  }

  // Update user score
  Future<User?> updateScore(String subjectName, int score, bool passed) async {
    final prefs = await _prefs;
    final currentUsername = prefs.getString(_keyCurrentUser);
    if (currentUsername == null) return null;

    final userKey = '$_prefixUser$currentUsername';
    final userJson = prefs.getString(userKey);
    if (userJson == null) return null;

    final user = User.fromJson(userJson);

    // Calculate highest score
    final currentHighest = user.highestScores[subjectName] ?? 0;
    if (score > currentHighest) {
      user.highestScores[subjectName] = score;
    }

    // Update last score and pass status
    user.lastScores[subjectName] = score;
    user.lastPassStatus[subjectName] = passed;

    // Save back to local storage
    await prefs.setString(userKey, user.toJson());
    return user;
  }
}
