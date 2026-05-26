import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../data/local_data.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
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
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  void _logout() async {
    await StorageService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
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

    // Calculate total tests taken and passed (offline metrics logic)
    int totalAttempted = 0;
    int totalPassed = 0;
    _currentUser?.lastScores.forEach((key, val) {
      totalAttempted++;
    });
    _currentUser?.lastPassStatus.forEach((key, passed) {
      if (passed) totalPassed++;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'User Profile',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              // User Avatar
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      width: 3.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                    child: Text(
                      (_currentUser?.name.isNotEmpty ?? false)
                          ? _currentUser!.name[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6366F1),
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Name and username
              Text(
                _currentUser?.name ?? 'User Name',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '@${_currentUser?.username ?? 'username'}',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 32.0),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Subjects Attempted',
                      totalAttempted.toString(),
                      Icons.quiz_rounded,
                      const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildMetricCard(
                      'Tests Passed',
                      totalPassed.toString(),
                      Icons.check_circle_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32.0),

              // Performance per subject title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Offline Scoreboard',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Dynamic score list
              ...quizSubjects.map((sub) {
                final lastScore = _currentUser?.lastScores[sub.name];
                final highestScore = _currentUser?.highestScores[sub.name];
                final passed = _currentUser?.lastPassStatus[sub.name];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sub.name.toLowerCase() == 'math'
                              ? Icons.calculate_rounded
                              : sub.name.toLowerCase() == 'science'
                                  ? Icons.science_rounded
                                  : Icons.menu_book_rounded,
                          color: const Color(0xFF6366F1),
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              lastScore != null
                                  ? 'Last Result: ${passed == true ? "Pass" : "Fail"} ($lastScore/${sub.questions.length})'
                                  : 'Not taken yet',
                              style: TextStyle(
                                color: lastScore != null
                                    ? (passed == true ? Colors.greenAccent : Colors.redAccent)
                                    : Colors.white38,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Highest',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            highestScore != null ? '$highestScore/${sub.questions.length}' : '—',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28.0),
          const SizedBox(height: 16.0),
          Text(
            val,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
