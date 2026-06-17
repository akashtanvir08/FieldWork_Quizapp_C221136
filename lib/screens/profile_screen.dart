import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../services/storage_service.dart';
import '../services/database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    int totalAttempted = 0;
    int totalPassed = 0;
    _currentUser?.lastScores.forEach((key, val) {
      totalAttempted++;
    });
    _currentUser?.lastPassStatus.forEach((key, passed) {
      if (passed) totalPassed++;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'User Profile',
          style: GoogleFonts.outfit(
            color: theme.colorScheme.onSurface,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 3.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (_currentUser?.name.isNotEmpty ?? false)
                          ? _currentUser!.name[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.outfit(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                _currentUser?.name ?? 'User Name',
                style: GoogleFonts.outfit(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '@${_currentUser?.username ?? 'username'}',
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      theme,
                      'Subjects Attempted',
                      totalAttempted.toString(),
                      Icons.quiz_rounded,
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildMetricCard(
                      theme,
                      'Tests Passed',
                      totalPassed.toString(),
                      Icons.check_circle_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Offline Scoreboard',
                  style: GoogleFonts.outfit(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ..._subjects.map((sub) {
                final lastScore = _currentUser?.lastScores[sub.name];
                final highestScore = _currentUser?.highestScores[sub.name];
                final passed = _currentUser?.lastPassStatus[sub.name];

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sub.name.toLowerCase() == 'math'
                                ? Icons.calculate_rounded
                                : sub.name.toLowerCase() == 'science'
                                    ? Icons.science_rounded
                                    : Icons.menu_book_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
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
                                      ? (passed == true ? Colors.green[700] : theme.colorScheme.error)
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Highest',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              highestScore != null ? '$highestScore/${sub.questions.length}' : '—',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String val, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28.0),
            const SizedBox(height: 16.0),
            Text(
              val,
              style: GoogleFonts.outfit(
                color: theme.colorScheme.onSurface,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: GoogleFonts.inter(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
