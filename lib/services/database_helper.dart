import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../data/local_data.dart';

class DatabaseHelper {
  static const String _dbName = 'quiz_app.db';
  static const int _dbVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        username TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'student'
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT NOT NULL,
        iconName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer_index INTEGER NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        passed INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    await db.insert('users', {
      'username': 'admin',
      'name': 'Administrator',
      'password': 'admin123',
      'role': 'admin',
    });

    for (final subject in quizSubjects) {
      final subjectId = await db.insert('subjects', {
        'name': subject.name,
        'description': subject.description,
        'iconName': subject.iconName,
      });

      for (final question in subject.questions) {
        await db.insert('questions', {
          'subject_id': subjectId,
          'question_text': question.questionText,
          'options': jsonEncode(question.options),
          'correct_answer_index': question.correctAnswerIndex,
        });
      }
    }
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'username': user.username,
      'name': user.name,
      'password': user.password,
      'role': 'student',
    });
  }

  Future<int> insertUserWithRole(User user, String role) async {
    final db = await database;
    return await db.insert('users', {
      'username': user.username,
      'name': user.name,
      'password': user.password,
      'role': role,
    });
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getAllSubjectsRaw() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await database;
    final subjectsList = await db.query('subjects');
    final List<Subject> list = [];

    for (final subMap in subjectsList) {
      final subjectId = subMap['id'] as int;
      final subjectName = subMap['name'] as String;
      final subjectDesc = subMap['description'] as String;
      final subjectIcon = subMap['iconName'] as String;

      final questionsList = await getQuestionsForSubject(subjectId);
      list.add(Subject(
        name: subjectName,
        description: subjectDesc,
        iconName: subjectIcon,
        questions: questionsList,
      ));
    }
    return list;
  }

  Future<int> insertSubject(String name, String description, String iconName) async {
    final db = await database;
    return await db.insert('subjects', {
      'name': name,
      'description': description,
      'iconName': iconName,
    });
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Question>> getQuestionsForSubject(int subjectId) async {
    final db = await database;
    final results = await db.query(
      'questions',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    return results.map((qMap) {
      final optionsJson = qMap['options'] as String;
      final optionsList = List<String>.from(jsonDecode(optionsJson) as List);
      return Question(
        questionText: qMap['question_text'] as String,
        options: optionsList,
        correctAnswerIndex: qMap['correct_answer_index'] as int,
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSubjectRaw(int subjectId) async {
    final db = await database;
    return await db.query(
      'questions',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<int> insertQuestion(int subjectId, String questionText, List<String> options, int correctAnswerIndex) async {
    final db = await database;
    return await db.insert('questions', {
      'subject_id': subjectId,
      'question_text': questionText,
      'options': jsonEncode(options),
      'correct_answer_index': correctAnswerIndex,
    });
  }

  Future<int> updateQuestion(int id, String questionText, List<String> options, int correctAnswerIndex) async {
    final db = await database;
    return await db.update(
      'questions',
      {
        'question_text': questionText,
        'options': jsonEncode(options),
        'correct_answer_index': correctAnswerIndex,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertScore(String username, String subjectName, int score, int totalQuestions, bool passed) async {
    final db = await database;
    return await db.insert('scores', {
      'username': username,
      'subject_name': subjectName,
      'score': score,
      'total_questions': totalQuestions,
      'passed': passed ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserScores(String username) async {
    final db = await database;
    return await db.query(
      'scores',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllStudentScores() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT scores.*, users.name as student_name
      FROM scores
      INNER JOIN users ON scores.username = users.username
      ORDER BY scores.timestamp DESC
    ''');
  }

  Future<Map<String, int>> getUserHighestScores(String username) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT subject_name, MAX(score) as max_score
      FROM scores
      WHERE username = ?
      GROUP BY subject_name
    ''', [username]);

    final Map<String, int> highest = {};
    for (final row in results) {
      highest[row['subject_name'] as String] = row['max_score'] as int;
    }
    return highest;
  }

  Future<Map<String, int>> getUserLastScores(String username) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT s.subject_name, s.score
      FROM scores s
      INNER JOIN (
        SELECT subject_name, MAX(timestamp) as max_ts
        FROM scores
        WHERE username = ?
        GROUP BY subject_name
      ) latest ON s.subject_name = latest.subject_name AND s.timestamp = latest.max_ts
      WHERE s.username = ?
    ''', [username, username]);

    final Map<String, int> last = {};
    for (final row in results) {
      last[row['subject_name'] as String] = row['score'] as int;
    }
    return last;
  }

  Future<Map<String, bool>> getUserLastPassStatus(String username) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT s.subject_name, s.passed
      FROM scores s
      INNER JOIN (
        SELECT subject_name, MAX(timestamp) as max_ts
        FROM scores
        WHERE username = ?
        GROUP BY subject_name
      ) latest ON s.subject_name = latest.subject_name AND s.timestamp = latest.max_ts
      WHERE s.username = ?
    ''', [username, username]);

    final Map<String, bool> status = {};
    for (final row in results) {
      status[row['subject_name'] as String] = (row['passed'] as int) == 1;
    }
    return status;
  }
}
