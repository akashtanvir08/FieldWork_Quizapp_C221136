import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/storage_service.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;
  List<Subject> _subjects = [];
  List<Map<String, dynamic>> _studentScores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper.instance;
    final subjects = await db.getAllSubjects();
    final scores = await db.getAllStudentScores();

    setState(() {
      _subjects = subjects;
      _studentScores = scores;
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Admin Console',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24.0,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildManageQuizzesTab(),
                _buildStudentScoresTab(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
            _loadData();
          },
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_rounded),
              label: 'Manage Quizzes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Student Scores',
            ),
          ],
        ),
      ),
    );
  }

  // ================= MANAGE QUIZZES TAB =================

  Widget _buildManageQuizzesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quiz Subjects',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSubjectDialog,
                icon: const Icon(Icons.add_rounded, size: 18.0),
                label: const Text('Add Subject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'Create subjects and add or manage questions below.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: _subjects.isEmpty
                ? Center(
                    child: Text(
                      'No subjects found. Create one to begin!',
                      style: GoogleFonts.inter(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: _subjects.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return _buildSubjectManageCard(subject);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectManageCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToQuestionsManager(subject),
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(subject.iconName),
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
                        subject.name,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        subject.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${subject.questions.length}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6366F1),
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= STUDENT SCORES TAB =================

  Widget _buildStudentScoresTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            'Student Performance Scoreboard',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Track recent offline test results taken by students.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: _studentScores.isEmpty
                ? Center(
                    child: Text(
                      'No student scores recorded yet.',
                      style: GoogleFonts.inter(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: _studentScores.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final scoreMap = _studentScores[index];
                      final score = scoreMap['score'] as int;
                      final totalQuestions = scoreMap['total_questions'] as int;
                      final passed = scoreMap['passed'] as int == 1;
                      final studentName = scoreMap['student_name'] as String? ?? 'Student';
                      final subjectName = scoreMap['subject_name'] as String;
                      final rawTime = scoreMap['timestamp'] as String;
                      final date = DateTime.tryParse(rawTime)?.toLocal().toString().substring(0, 16) ?? rawTime;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundColor: (passed ? Colors.green : Colors.redAccent).withOpacity(0.15),
                              child: Text(
                                studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                style: TextStyle(
                                  color: passed ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '$subjectName • $date',
                                    style: const TextStyle(
                                      color: Colors.white54,
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
                                  '$score / $totalQuestions',
                                  style: TextStyle(
                                    color: passed ? Colors.greenAccent : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  passed ? 'PASSED' : 'FAILED',
                                  style: TextStyle(
                                    color: passed ? Colors.greenAccent.withOpacity(0.8) : Colors.redAccent.withOpacity(0.8),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= SUBJECT & QUESTION DIALOGS =================

  void _showAddSubjectDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = 'calculate';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text(
                'Create Subject',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Subject Name', Icons.title_rounded),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter subject name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: descController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: _buildInputDecoration('Description', Icons.description_rounded),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter description';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Select Icon:',
                        style: TextStyle(color: Colors.white70, fontSize: 13.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconSelectionButton('calculate', Icons.calculate_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton('science', Icons.science_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton('book', Icons.book_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton('history', Icons.history_edu_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await DatabaseHelper.instance.insertSubject(
                      nameController.text.trim(),
                      descController.text.trim(),
                      selectedIcon,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _loadData();
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconSelectionButton(String key, IconData icon, String currentSelected, ValueChanged<String> onTap) {
    final isSelected = currentSelected == key;
    return GestureDetector(
      onTap: () => onTap(key),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.white54, size: 24.0),
      ),
    );
  }

  // ================= QUESTIONS MANAGEMENT SCREEN NAV =================

  void _navigateToQuestionsManager(Subject subject) async {
    // We get the raw subject id from database to manage questions
    final db = DatabaseHelper.instance;
    final subjectsRaw = await db.getAllSubjectsRaw();
    int? subjectId;
    for (final s in subjectsRaw) {
      if (s['name'] == subject.name) {
        subjectId = s['id'] as int;
        break;
      }
    }

    if (subjectId == null) return;

    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionsManagerScreen(subjectName: subject.name, subjectId: subjectId!),
        ),
      );
      _loadData(); // reload
    }
  }

  // ================= HELPERS =================

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'book':
        return Icons.book_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      prefixIcon: Icon(icon, color: Colors.white30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }
}

// ==============================================================
// QUESTIONS MANAGER SCREEN
// ==============================================================

class QuestionsManagerScreen extends StatefulWidget {
  final String subjectName;
  final int subjectId;

  const QuestionsManagerScreen({
    Key? key,
    required this.subjectName,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<QuestionsManagerScreen> createState() => _QuestionsManagerScreenState();
}

class _QuestionsManagerScreenState extends State<QuestionsManagerScreen> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });
    final q = await DatabaseHelper.instance.getQuestionsForSubjectRaw(widget.subjectId);
    setState(() {
      _questions = q;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          '${widget.subjectName} Questions',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            tooltip: 'Delete Subject',
            onPressed: _confirmDeleteSubject,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Questions: ${_questions.length}',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 14.0, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showQuestionDialog(null),
                        icon: const Icon(Icons.add_rounded, size: 16.0),
                        label: const Text('Add Question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: _questions.isEmpty
                        ? const Center(
                            child: Text('No questions. Add questions to this subject!', style: TextStyle(color: Colors.white38)),
                          )
                        : ListView.builder(
                            itemCount: _questions.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final q = _questions[index];
                              return _buildQuestionTile(q, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionTile(Map<String, dynamic> q, int index) {
    final text = q['question_text'] as String;
    final id = q['id'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q${index + 1}. ',
                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 18.0),
                onPressed: () => _showQuestionDialog(q),
              ),
              const SizedBox(width: 10.0),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18.0),
                onPressed: () => _deleteQuestion(id),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // Options previews
          ..._buildOptionsListPreview(q),
        ],
      ),
    );
  }

  List<Widget> _buildOptionsListPreview(Map<String, dynamic> q) {
    final optionsRaw = q['options'] as String;
    final List<String> options = List<String>.from(jsonDecode(optionsRaw) as List);
    final correctIdx = q['correct_answer_index'] as int;

    return List.generate(options.length, (idx) {
      final isCorrect = idx == correctIdx;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          children: [
            Container(
              width: 18.0,
              height: 18.0,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx),
                  style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                options[idx],
                style: TextStyle(
                  color: isCorrect ? Colors.greenAccent : Colors.white60,
                  fontSize: 13.0,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showQuestionDialog(Map<String, dynamic>? editingQuestion) {
    final formKey = GlobalKey<FormState>();
    final questionController = TextEditingController();
    final optA = TextEditingController();
    final optB = TextEditingController();
    final optC = TextEditingController();
    final optD = TextEditingController();
    int correctIdx = 0;

    if (editingQuestion != null) {
      questionController.text = editingQuestion['question_text'] as String;
      final options = List<String>.from(jsonDecode(editingQuestion['options'] as String) as List);
      if (options.length >= 4) {
        optA.text = options[0];
        optB.text = options[1];
        optC.text = options[2];
        optD.text = options[3];
      }
      correctIdx = editingQuestion['correct_answer_index'] as int;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text(
                editingQuestion == null ? 'Add Question' : 'Edit Question',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: questionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: _buildInputDecoration('Question text'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter question';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optA,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Option A'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option A';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optB,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Option B'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option B';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optC,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Option C'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option C';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optD,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Option D'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option D';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correct Option:',
                          style: TextStyle(color: Colors.white70, fontSize: 13.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          final label = String.fromCharCode(65 + index); // A, B, C, D
                          final isSelected = correctIdx == index;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => correctIdx = index);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: isSelected ? Colors.green : Colors.white24),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final options = [
                      optA.text.trim(),
                      optB.text.trim(),
                      optC.text.trim(),
                      optD.text.trim(),
                    ];

                    if (editingQuestion == null) {
                      await DatabaseHelper.instance.insertQuestion(
                        widget.subjectId,
                        questionController.text.trim(),
                        options,
                        correctIdx,
                      );
                    } else {
                      await DatabaseHelper.instance.updateQuestion(
                        editingQuestion['id'] as int,
                        questionController.text.trim(),
                        options,
                        correctIdx,
                      );
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _loadQuestions();
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteQuestion(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Question?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this question?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteQuestion(id);
      _loadQuestions();
    }
  }

  void _confirmDeleteSubject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Subject?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete the subject "${widget.subjectName}" and all of its questions? This action is permanent.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteSubject(widget.subjectId);
      if (mounted) {
        Navigator.of(context).pop(); // Go back to subject list
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }
}
