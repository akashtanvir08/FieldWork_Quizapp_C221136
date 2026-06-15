import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../services/storage_service.dart';
import '../services/database_helper.dart';
import '../widgets/subject_card.dart';
import 'quiz_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({Key? key}) : super(key: key);

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  User? _currentUser;
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await StorageService.instance.getCurrentUser();
    final subjects = await DatabaseHelper.instance.getAllSubjects();
    setState(() {
      _currentUser = user;
      _subjects = subjects;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _currentUser?.name ?? 'Guest',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 26.0,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                    child: Text(
                      (_currentUser?.name.isNotEmpty ?? false)
                          ? _currentUser!.name[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6366F1),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36.0),

              // Title
              Text(
                'Choose a Subject',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Select a category to start the 30-second-per-question quiz.',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 24.0),

              // List of Subjects
              Expanded(
                child: _subjects.isEmpty
                    ? Center(
                        child: Text(
                          'No subjects available. Ask an Admin to add some!',
                          style: GoogleFonts.inter(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _subjects.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final subject = _subjects[index];
                          final highestScore = _currentUser?.highestScores[subject.name];
                          return SubjectCard(
                            subject: subject,
                            highestScore: highestScore,
                            totalQuestions: subject.questions.length,
                            onTap: () async {
                              // Open QuizScreen and reload user data on return (to show new scores)
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(subject: subject),
                                ),
                              );
                              _loadUserData();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
