import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class StorageService {
  static const String _keyCurrentUser = 'current_user_username';

  // Private constructor
  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  // Initialize helper (optional, SharedPreferences is loaded async)
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Signup
  Future<bool> signUpUser(String name, String username, String password, {String role = 'student'}) async {
    final dbUser = await DatabaseHelper.instance.getUser(username);
    if (dbUser != null) {
      return false; // User already exists
    }

    final newUser = User(
      username: username,
      name: name,
      password: password,
      role: role,
      highestScores: {},
      lastScores: {},
      lastPassStatus: {},
    );

    await DatabaseHelper.instance.insertUserWithRole(newUser, role);
    return true;
  }

  // Login
  Future<User?> loginUser(String username, String password) async {
    final dbUser = await DatabaseHelper.instance.getUser(username);
    if (dbUser == null) {
      return null; // User not found
    }

    if (dbUser['password'] == password) {
      final prefs = await _prefs;
      // Save current session in SharedPreferences
      await prefs.setString(_keyCurrentUser, username);
      
      // Load user metrics and return complete User object
      return await getCurrentUser();
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

    final dbUser = await DatabaseHelper.instance.getUser(currentUsername);
    if (dbUser == null) return null;

    final db = DatabaseHelper.instance;
    final highestScores = await db.getUserHighestScores(currentUsername);
    final lastScores = await db.getUserLastScores(currentUsername);
    final lastPassStatus = await db.getUserLastPassStatus(currentUsername);

    return User(
      username: dbUser['username'] as String,
      name: dbUser['name'] as String,
      password: dbUser['password'] as String,
      role: dbUser['role'] as String? ?? 'student',
      highestScores: highestScores,
      lastScores: lastScores,
      lastPassStatus: lastPassStatus,
    );
  }

  // Update user score
  Future<User?> updateScore(String subjectName, int score, bool passed) async {
    final prefs = await _prefs;
    final currentUsername = prefs.getString(_keyCurrentUser);
    if (currentUsername == null) return null;

    final db = DatabaseHelper.instance;
    
    // Find subject ID to calculate total questions
    final subjects = await db.getAllSubjectsRaw();
    int totalQuestions = 5; // fallback
    for (final s in subjects) {
      if (s['name'] == subjectName) {
        final q = await db.getQuestionsForSubjectRaw(s['id'] as int);
        totalQuestions = q.length;
        break;
      }
    }

    // Insert score record
    await db.insertScore(currentUsername, subjectName, score, totalQuestions, passed);
    
    return await getCurrentUser();
  }
}
