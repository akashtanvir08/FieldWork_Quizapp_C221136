import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/question_model.dart';
import '../models/subject_model.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;

  const QuizScreen({Key? key, required this.subject}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  Timer? _timer;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = -1;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    _timer?.cancel();

    final currentQuestion = widget.subject.questions[_currentQuestionIndex];
    final isCorrect = index == currentQuestion.correctAnswerIndex;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < widget.subject.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startTimer();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            subjectName: widget.subject.name,
            score: _score,
            totalQuestions: widget.subject.questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = widget.subject.questions[_currentQuestionIndex];
    final percent = _timeLeft / 30.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject.name,
          style: GoogleFonts.outfit(
            color: theme.colorScheme.onSurface,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Quit Quiz?'),
                content: const Text(
                  'Are you sure you want to quit? Your current progress will be lost.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('Quit', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: _timeLeft <= 10 ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 8.0,
                      percent: percent,
                      barRadius: const Radius.circular(4.0),
                      progressColor: _timeLeft <= 10 ? theme.colorScheme.error : theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      animation: false,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    '${_timeLeft}s',
                    style: GoogleFonts.outfit(
                      color: _timeLeft <= 10 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(
                'QUESTION ${_currentQuestionIndex + 1} OF ${widget.subject.questions.length}',
                style: GoogleFonts.inter(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12.0),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      currentQuestion.questionText,
                      style: GoogleFonts.outfit(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, idx) {
                    final optionText = currentQuestion.options[idx];
                    return _buildOptionButton(theme, idx, optionText, currentQuestion);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(ThemeData theme, int idx, String optionText, Question currentQuestion) {
    Color cardColor = theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outlineVariant;
    Color textColor = theme.colorScheme.onSurface;

    if (_isAnswered) {
      if (idx == currentQuestion.correctAnswerIndex) {
        cardColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green[800]!;
      } else if (idx == _selectedAnswerIndex) {
        cardColor = theme.colorScheme.errorContainer.withOpacity(0.5);
        borderColor = theme.colorScheme.error;
        textColor = theme.colorScheme.error;
      }
    } else {
      if (_selectedAnswerIndex == idx) {
        borderColor = theme.colorScheme.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(idx),
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: _isAnswered && idx == currentQuestion.correctAnswerIndex
                        ? Colors.green
                        : _isAnswered && idx == _selectedAnswerIndex
                            ? theme.colorScheme.error
                            : theme.colorScheme.outlineVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + idx),
                      style: TextStyle(
                        color: _isAnswered &&
                                (idx == currentQuestion.correctAnswerIndex ||
                                    idx == _selectedAnswerIndex)
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_isAnswered && idx == currentQuestion.correctAnswerIndex)
                  const Icon(Icons.check_circle_rounded, color: Colors.green)
                else if (_isAnswered && idx == _selectedAnswerIndex)
                  Icon(Icons.cancel_rounded, color: theme.colorScheme.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
