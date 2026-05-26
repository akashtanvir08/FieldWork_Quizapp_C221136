import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/main.dart';

void main() {
  testWidgets('Quiz App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuizApp(isLoggedIn: false));

    // Verify that the login screen is loaded (it should show "Welcome Back")
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
