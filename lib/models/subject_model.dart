import 'question_model.dart';

class Subject {
  final String name;
  final String description;
  final String iconName;
  final List<Question> questions;

  Subject({
    required this.name,
    required this.description,
    required this.iconName,
    required this.questions,
  });
}
