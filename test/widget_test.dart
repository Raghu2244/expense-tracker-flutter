import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
