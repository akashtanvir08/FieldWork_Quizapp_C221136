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

  Color _getSubjectColor(BuildContext context, String subjectName) {
    final theme = Theme.of(context);
    switch (subjectName.toLowerCase()) {
      case 'math':
        return Colors.orange;
      case 'science':
        return Colors.teal;
      case 'english':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSubjectColor(context, subject.name);
    final icon = _getIcon(subject.iconName);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  size: 28.0,
                  color: color,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subject.description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13.0,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 14.0,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          highestScore != null
                              ? 'Best Score: $highestScore/${totalQuestions ?? 5}'
                              : 'Best Score: -',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
