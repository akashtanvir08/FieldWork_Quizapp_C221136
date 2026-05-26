import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatefulWidget {
  final String subjectName;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    Key? key,
    required this.subjectName,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = true;
  bool _hasPassed = false;

  @override
  void initState() {
    super.initState();
    _saveQuizResult();
  }

  void _saveQuizResult() async {
    // Pass if score >= 3
    final passed = widget.score >= 3;
    setState(() {
      _hasPassed = passed;
    });

    // Save score using storage service
    await StorageService.instance.updateScore(widget.subjectName, widget.score, passed);

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    final passGradient = [const Color(0xFF059669), const Color(0xFF10B981)]; // Emerald
    final failGradient = [const Color(0xFFDC2626), const Color(0xFFEF4444)]; // Red/Crimson

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Visual pass/fail indicator (Big Circle or Icon)
              Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _hasPassed ? passGradient : failGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_hasPassed ? passGradient : failGradient).first.withOpacity(0.3),
                      blurRadius: 20.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _hasPassed ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
                  size: 70.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 36.0),

              // Status Title
              Text(
                _hasPassed ? 'Congratulations!' : 'Keep Practicing!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),

              // Description
              Text(
                _hasPassed
                    ? 'You passed the ${widget.subjectName} quiz!'
                    : 'You did not pass the ${widget.subjectName} quiz this time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 48.0),

              // Score details card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR SCORE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.score}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 64.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${widget.totalQuestions}',
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Pass / Fail badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: _hasPassed ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: _hasPassed ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _hasPassed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          color: _hasPassed ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Navigation buttons
              CustomButton(
                text: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pop(); // Back to subject list / Home
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
