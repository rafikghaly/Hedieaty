import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/main.dart';
import 'package:provider/provider.dart';
import 'package:hedieaty/controllers/theme_notifier.dart';
import 'package:integration_test/integration_test.dart';
import 'shared_setup.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await sharedSetup();
  });

  testWidgets('Sign in with wrong password and verify error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(); // Ensure initial load

    // Ensure SignInPage is loaded
    expect(find.byKey(const Key('SignInPageKey')), findsOneWidget);

    // Enter valid email and wrong password
    await tester.enterText(find.byKey(const Key('emailField')), 'rafik@gmail.com');
    await tester.pumpAndSettle(); // Ensure text is entered

    await tester.enterText(find.byKey(const Key('passwordField')), 'wrongpassword');
    await tester.pumpAndSettle(); // Ensure text is entered

    // Hide the keyboard after entering password
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Tap the sign-in button
    await tester.ensureVisible(find.byKey(const Key('signInButton')));
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle(); // Ensure button is tapped and response is processed

    // Verify that the SignInPage is still visible (incorrect password scenario)
    expect(find.byKey(const Key('SignInPageKey')), findsOneWidget);
  });

  testWidgets('Sign in with valid credentials and navigate to MainPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle(); // Ensure initial load

    // Ensure SignInPage is loaded
    expect(find.byKey(const Key('SignInPageKey')), findsOneWidget);

    // Enter valid email and correct password
    await tester.enterText(find.byKey(const Key('emailField')), 'rafik@gmail.com');
    await tester.pumpAndSettle(); // Ensure text is entered

    // Clear the password field
    await tester.enterText(find.byKey(const Key('passwordField')), '');
    await tester.pumpAndSettle(); // Ensure field is cleared

    await tester.enterText(find.byKey(const Key('passwordField')), '12345678');
    await tester.pumpAndSettle(); // Ensure text is entered

    // Hide the keyboard after entering password
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Tap the sign-in button
    await tester.ensureVisible(find.byKey(const Key('signInButton')));
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle(); // Ensure button is tapped and response is processed

    await Future.delayed(const Duration(seconds: 5));

    // Pump the widget tree again to process the navigation
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));

    // Verify that the SignInPage is no longer visible, indicating successful navigation
    expect(find.byKey(const Key('SignInPageKey')), findsNothing);

    // Ensure that MainPage is visible after the navigation
    expect(find.byKey(const Key('MainPageKey')), findsOneWidget);

  });
}
