import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/storage_service.dart';
import '../models/subject_model.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Console',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildManageQuizzesTab(theme),
                _buildStudentScoresTab(theme),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          _loadData();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_rounded),
            label: 'Manage Quizzes',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Student Scores',
          ),
        ],
      ),
    );
  }

  Widget _buildManageQuizzesTab(ThemeData theme) {
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
                  color: theme.colorScheme.onSurface,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: _showAddSubjectDialog,
                icon: const Icon(Icons.add_rounded, size: 18.0),
                label: const Text('Add Subject'),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'Create subjects and add or manage questions below.',
            style: GoogleFonts.inter(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: _subjects.isEmpty
                ? Center(
                    child: Text(
                      'No subjects found. Create one to begin!',
                      style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: _subjects.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return _buildSubjectManageCard(theme, subject);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectManageCard(ThemeData theme, Subject subject) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToQuestionsManager(subject),
        borderRadius: BorderRadius.circular(16.0),
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
                  _getIconData(subject.iconName),
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
                      subject.name,
                      style: GoogleFonts.outfit(
                        color: theme.colorScheme.onSurface,
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
                        color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.primary,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Questions',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8.0),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentScoresTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            'Student Performance Scoreboard',
            style: GoogleFonts.outfit(
              color: theme.colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Track recent offline test results taken by students.',
            style: GoogleFonts.inter(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: _studentScores.isEmpty
                ? Center(
                    child: Text(
                      'No student scores recorded yet.',
                      style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant),
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

                      final color = passed ? Colors.green : theme.colorScheme.error;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12.0),
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
                              CircleAvatar(
                                radius: 20.0,
                                backgroundColor: color.withOpacity(0.1),
                                child: Text(
                                  studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                  style: TextStyle(
                                    color: color,
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '$subjectName • $date',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurfaceVariant,
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
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    passed ? 'PASSED' : 'FAILED',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

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
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Create Subject'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: _buildInputDecoration(theme, 'Subject Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter subject name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: _buildInputDecoration(theme, 'Description'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter description';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Select Icon:',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconSelectionButton(theme, 'calculate', Icons.calculate_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton(theme, 'science', Icons.science_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton(theme, 'book', Icons.book_rounded, selectedIcon, (val) {
                            setDialogState(() => selectedIcon = val);
                          }),
                          _buildIconSelectionButton(theme, 'history', Icons.history_edu_rounded, selectedIcon, (val) {
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
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconSelectionButton(ThemeData theme, String key, IconData icon, String currentSelected, ValueChanged<String> onTap) {
    final isSelected = currentSelected == key;
    return GestureDetector(
      onTap: () => onTap(key),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant, size: 24.0),
      ),
    );
  }

  void _navigateToQuestionsManager(Subject subject) async {
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
      _loadData();
    }
  }

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

  InputDecoration _buildInputDecoration(ThemeData theme, String hint) {
    return InputDecoration(
      labelText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.subjectName} Questions',
          style: GoogleFonts.outfit(color: theme.colorScheme.onSurface, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever_rounded, color: theme.colorScheme.error),
            tooltip: 'Delete Subject',
            onPressed: _confirmDeleteSubject,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant, fontSize: 14.0, fontWeight: FontWeight.w600),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showQuestionDialog(null),
                        icon: const Icon(Icons.add_rounded, size: 16.0),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: _questions.isEmpty
                        ? Center(
                            child: Text('No questions. Add questions to this subject!', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                          )
                        : ListView.builder(
                            itemCount: _questions.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final q = _questions[index];
                              return _buildQuestionTile(theme, q, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionTile(ThemeData theme, Map<String, dynamic> q, int index) {
    final text = q['question_text'] as String;
    final id = q['id'] as int;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}. ',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_rounded, size: 18.0),
                  onPressed: () => _showQuestionDialog(q),
                ),
                const SizedBox(width: 10.0),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 18.0),
                  onPressed: () => _deleteQuestion(id),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ..._buildOptionsListPreview(theme, q),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionsListPreview(ThemeData theme, Map<String, dynamic> q) {
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
                color: isCorrect ? Colors.green : theme.colorScheme.outlineVariant.withOpacity(0.5),
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
                  color: isCorrect ? Colors.green[700] : theme.colorScheme.onSurfaceVariant,
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
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(
                editingQuestion == null ? 'Add Question' : 'Edit Question',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: questionController,
                        maxLines: 2,
                        decoration: _buildInputDecoration(theme, 'Question text'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter question';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optA,
                        decoration: _buildInputDecoration(theme, 'Option A'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option A';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optB,
                        decoration: _buildInputDecoration(theme, 'Option B'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option B';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optC,
                        decoration: _buildInputDecoration(theme, 'Option C'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option C';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: optD,
                        decoration: _buildInputDecoration(theme, 'Option D'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter Option D';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correct Option:',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          final label = String.fromCharCode(65 + index);
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
                                border: Border.all(color: isSelected ? Colors.green : theme.colorScheme.outlineVariant),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
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
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteQuestion(int id) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteQuestion(id);
      _loadQuestions();
    }
  }

  void _confirmDeleteSubject() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
          'Are you sure you want to delete the subject "${widget.subjectName}" and all of its questions? This action is permanent.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete', style: TextStyle(color: theme.colorScheme.error))),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteSubject(widget.subjectId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  InputDecoration _buildInputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
