import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final int? highestScore;
  final int? totalQuestions;

  const SubjectCard({
    Key? key,
    required this.subject,
    required this.onTap,
    this.highestScore,
    this.totalQuestions,
  }) : super(key: key);

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  List<Color> _getGradientColors(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'math':
        return [const Color(0xFFFF9966), const Color(0xFFFF5E62)]; // Orange/Red
      case 'science':
        return [const Color(0xFF00B0FF), const Color(0xFF00E5FF)]; // Cyan/Blue
      case 'english':
        return [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]; // Purple/Indigo
      default:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradientColors(subject.name);
    final icon = _getIcon(subject.iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Icon container with Glassmorphism feel
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 32.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20.0),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        subject.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14.0,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 16.0,
                            color: Colors.yellow.shade200,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            highestScore != null
                                ? 'Best: $highestScore/${totalQuestions ?? 5}'
                                : 'Best: -',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
