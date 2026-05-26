class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  // Convert to Map for potential future extensions, or keeping it clean
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
    );
  }
}
