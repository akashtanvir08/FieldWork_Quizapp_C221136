import '../models/question_model.dart';
import '../models/subject_model.dart';

final List<Subject> quizSubjects = [
  Subject(
    name: 'Math',
    description: 'Test your algebra, geometry, and arithmetic skills.',
    iconName: 'calculate',
    questions: [
      Question(
        questionText: 'What is the value of 5 + 7 * 2?',
        options: ['24', '19', '17', '22'],
        correctAnswerIndex: 1, // 5 + 14 = 19
      ),
      Question(
        questionText: 'Solve for x: 3x - 7 = 8',
        options: ['x = 3', 'x = 4', 'x = 5', 'x = 6'],
        correctAnswerIndex: 2, // 3x = 15 => x = 5
      ),
      Question(
        questionText: 'What is the square root of 144?',
        options: ['12', '14', '16', '10'],
        correctAnswerIndex: 0,
      ),
      Question(
        questionText: 'How many degrees are in a right-angled triangle\'s internal angles total?',
        options: ['90°', '180°', '360°', '270°'],
        correctAnswerIndex: 1,
      ),
      Question(
        questionText: 'Which of these is a prime number?',
        options: ['9', '15', '21', '17'],
        correctAnswerIndex: 3,
      ),
    ],
  ),
  Subject(
    name: 'Science',
    description: 'Explore physics, chemistry, biology, and the cosmos.',
    iconName: 'science',
    questions: [
      Question(
        questionText: 'Which planet is known as the "Red Planet"?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswerIndex: 1,
      ),
      Question(
        questionText: 'What is the chemical symbol for Water?',
        options: ['H2O', 'CO2', 'NaCl', 'O2'],
        correctAnswerIndex: 0,
      ),
      Question(
        questionText: 'What is the powerhouse of the cell?',
        options: ['Nucleus', 'Ribosome', 'Mitochondria', 'Chloroplast'],
        correctAnswerIndex: 2,
      ),
      Question(
        questionText: 'What gas do humans breathe out as waste?',
        options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
        correctAnswerIndex: 2,
      ),
      Question(
        questionText: 'Which of the following is NOT a state of matter?',
        options: ['Solid', 'Liquid', 'Gas', 'Energy'],
        correctAnswerIndex: 3,
      ),
    ],
  ),
  Subject(
    name: 'English',
    description: 'Check your grammar, vocabulary, and sentence structures.',
    iconName: 'book',
    questions: [
      Question(
        questionText: 'Choose the correct past tense of the verb "go":',
        options: ['Goed', 'Went', 'Gone', 'Going'],
        correctAnswerIndex: 1,
      ),
      Question(
        questionText: 'What is a person, place, or thing called in grammar?',
        options: ['Verb', 'Adjective', 'Noun', 'Adverb'],
        correctAnswerIndex: 2,
      ),
      Question(
        questionText: 'Find the synonym for the word "Vast":',
        options: ['Tiny', 'Huge', 'Narrow', 'Short'],
        correctAnswerIndex: 1,
      ),
      Question(
        questionText: 'Identify the antonym of the word "Polite":',
        options: ['Kind', 'Rude', 'Gentle', 'Smart'],
        correctAnswerIndex: 1,
      ),
      Question(
        questionText: 'Complete the sentence: "Neither of the options ___ correct."',
        options: ['are', 'is', 'were', 'am'],
        correctAnswerIndex: 1, // "Neither ... is"
      ),
    ],
  ),
];
