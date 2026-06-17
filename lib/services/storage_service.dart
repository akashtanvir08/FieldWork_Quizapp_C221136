import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class StorageService {
  static const String _keyCurrentUser = 'current_user_username';

  StorageService._privateConstructor();
  static final StorageService instance = StorageService._privateConstructor();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<bool> signUpUser(String name, String username, String password, {String role = 'student'}) async {
    final dbUser = await DatabaseHelper.instance.getUser(username);
    if (dbUser != null) {
      return false;
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

  Future<User?> loginUser(String username, String password) async {
    final dbUser = await DatabaseHelper.instance.getUser(username);
    if (dbUser == null) {
      return null;
    }

    if (dbUser['password'] == password) {
      final prefs = await _prefs;
      await prefs.setString(_keyCurrentUser, username);
      return await getCurrentUser();
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_keyCurrentUser);
  }

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

  Future<User?> updateScore(String subjectName, int score, bool passed) async {
    final prefs = await _prefs;
    final currentUsername = prefs.getString(_keyCurrentUser);
    if (currentUsername == null) return null;

    final db = DatabaseHelper.instance;
    
    final subjects = await db.getAllSubjectsRaw();
    int totalQuestions = 5;
    for (final s in subjects) {
      if (s['name'] == subjectName) {
        final q = await db.getQuestionsForSubjectRaw(s['id'] as int);
        totalQuestions = q.length;
        break;
      }
    }

    await db.insertScore(currentUsername, subjectName, score, totalQuestions, passed);
    
    return await getCurrentUser();
  }
}
