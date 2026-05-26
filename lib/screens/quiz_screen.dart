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

  // Timer properties
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question

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
        // Time is up! Auto move or select empty answer
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = -1; // Indicates time-out/no answer
    });

    // Wait a brief second to let user see they timed out, then go to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _goToNextQuestion();
      }
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return; // Prevent multiple selection

    _timer?.cancel(); // Pause the timer

    final currentQuestion = widget.subject.questions[_currentQuestionIndex];
    final isCorrect = index == currentQuestion.correctAnswerIndex;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Delay showing next question to let user see feedback (correct/incorrect)
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
      // Completed the quiz! Save score and navigate to ResultScreen
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
    final currentQuestion = widget.subject.questions[_currentQuestionIndex];
    final percent = _timeLeft / 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.subject.name,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            // Confirm quit dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: const Text('Quit Quiz?', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Are you sure you want to quit? Your current progress will be lost.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close quiz screen
                    },
                    child: const Text('Quit', style: TextStyle(color: Colors.redAccent)),
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
              // Timer Progress Bar
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: _timeLeft <= 10 ? Colors.redAccent : const Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 8.0,
                      percent: percent,
                      barRadius: const Radius.circular(4.0),
                      progressColor: _timeLeft <= 10 ? Colors.redAccent : const Color(0xFF6366F1),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      animation: false,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    '${_timeLeft}s',
                    style: GoogleFonts.outfit(
                      color: _timeLeft <= 10 ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Question status
              Text(
                'QUESTION ${_currentQuestionIndex + 1} OF ${widget.subject.questions.length}',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12.0),

              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  currentQuestion.questionText,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),

              // Options list
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, idx) {
                    final optionText = currentQuestion.options[idx];
                    return _buildOptionButton(idx, optionText, currentQuestion);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int idx, String optionText, Question currentQuestion) {
    Color cardColor = Colors.white.withOpacity(0.04);
    Color borderColor = Colors.white.withOpacity(0.08);
    Color textColor = Colors.white;

    if (_isAnswered) {
      if (idx == currentQuestion.correctAnswerIndex) {
        // Correct answer gets highlighted green
        cardColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
        textColor = Colors.greenAccent;
      } else if (idx == _selectedAnswerIndex) {
        // Selected wrong answer gets highlighted red
        cardColor = Colors.redAccent.withOpacity(0.2);
        borderColor = Colors.redAccent;
        textColor = Colors.redAccent;
      }
    } else {
      // Not answered yet, checking highlight hover/tap state simulation via border
      if (_selectedAnswerIndex == idx) {
        borderColor = const Color(0xFF6366F1);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(idx),
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            child: Row(
              children: [
                // Option symbol (A, B, C, D)
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: _isAnswered && idx == currentQuestion.correctAnswerIndex
                        ? Colors.green
                        : _isAnswered && idx == _selectedAnswerIndex
                            ? Colors.redAccent
                            : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + idx), // A, B, C, D
                      style: TextStyle(
                        color: _isAnswered &&
                                (idx == currentQuestion.correctAnswerIndex ||
                                    idx == _selectedAnswerIndex)
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_isAnswered && idx == currentQuestion.correctAnswerIndex)
                  const Icon(Icons.check_circle_rounded, color: Colors.green)
                else if (_isAnswered && idx == _selectedAnswerIndex)
                  const Icon(Icons.cancel_rounded, color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
