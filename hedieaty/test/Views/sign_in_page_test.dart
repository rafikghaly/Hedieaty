import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/views/sign_in_page.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('SignInPage has a title and buttons', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      Provider<Repository>(
        create: (_) => Repository(),
        child: MaterialApp(home: SignInPage()),
      ),
    );

    // Verify the title
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Verify email field
    expect(find.byKey(const Key('emailField')), findsOneWidget);

    // Verify password field
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    // Verify sign in button
    expect(find.byKey(const Key('signInButton')), findsOneWidget);
  });

  testWidgets('SignInPage won\'t redirect while invalid input and stays on sign in page', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      Provider<Repository>(
        create: (_) => Repository(),
        child: MaterialApp(home: SignInPage()),
      ),
    );

    // Enter invalid email and password
    await tester.enterText(find.byKey(const Key('emailField')), 'invalidemail');
    await tester.enterText(find.byKey(const Key('passwordField')), '123');

    // Tap the sign in button
    await tester.tap(find.byKey(const Key('signInButton')));

    // Rebuild the widget
    await tester.pumpAndSettle();

    // Verify that the SignInPage is still visible and didn't redirect
    expect(find.byType(SignInPage), findsOneWidget);

  });
}
