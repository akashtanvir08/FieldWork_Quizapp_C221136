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
    final passed = widget.score >= 3;
    setState(() {
      _hasPassed = passed;
    });

    await StorageService.instance.updateScore(widget.subjectName, widget.score, passed);

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSaving) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final color = _hasPassed ? Colors.green : theme.colorScheme.error;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              CircleAvatar(
                radius: 60.0,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  _hasPassed ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
                  size: 60.0,
                  color: color,
                ),
              ),
              const SizedBox(height: 36.0),
              Text(
                _hasPassed ? 'Congratulations!' : 'Keep Practicing!',
                style: GoogleFonts.outfit(
                  color: theme.colorScheme.onSurface,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                _hasPassed
                    ? 'You passed the ${widget.subjectName} quiz!'
                    : 'You did not pass the ${widget.subjectName} quiz this time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 40.0),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'YOUR SCORE',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.primary,
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
                              color: theme.colorScheme.onSurface,
                              fontSize: 64.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' / ${widget.totalQuestions}',
                            style: GoogleFonts.outfit(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _hasPassed ? 'PASSED' : 'FAILED',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              CustomButton(
                text: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pop();
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
