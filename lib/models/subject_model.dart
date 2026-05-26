import 'question_model.dart';

class Subject {
  final String name;
  final String description;
  final String iconName; // e.g., 'calculate' for math, 'science' for science, 'book' for English
  final List<Question> questions;

  Subject({
    required this.name,
    required this.description,
    required this.iconName,
    required this.questions,
  });
}
