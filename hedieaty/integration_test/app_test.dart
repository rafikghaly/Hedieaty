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

  group('End-to-End Test: Make an Event, gift, pledge', () {
    testWidgets('Sign in with valid credentials, navigate to EventsPage, add a public event, add a gift', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle(); // Ensure initial load

      // SignInPage loaded
      expect(find.byKey(const Key('SignInPageKey')), findsOneWidget);

      // Sign in with valid credentials
      await tester.enterText(find.byKey(const Key('emailField')), 'rafik@gmail.com');
      await tester.pumpAndSettle(); // Ensure text is entered
      await tester.enterText(find.byKey(const Key('passwordField')), '12345678');
      await tester.pumpAndSettle(); // Ensure text is entered
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('signInButton')));
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester.pumpAndSettle(); // Ensure button is tapped and response is processed

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));

      // Verify navigation to MainPage
      expect(find.byKey(const Key('MainPageKey')), findsOneWidget);

      /// Making a new Event ///
      // Navigate to EventsPage using the bottom navigation bar
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Add a public event
      await tester.tap(find.byKey(const Key('AddNewEvent')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('EventTitleField')), 'Public Event');
      await tester.pumpAndSettle();
      ////////////////////////////
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      ///////////////////////////
      await tester.enterText(find.byKey(const Key('EventCategoryField')), 'Birthday');
      await tester.pumpAndSettle();
      ////////////////////////////
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      ///////////////////////////
      await tester.enterText(find.byKey(const Key('EventLocationField')), 'Cairo');
      await tester.pumpAndSettle();
      ////////////////////////////
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      ///////////////////////////
      await tester.enterText(find.byKey(const Key('EventDescriptionField')), 'This is a public event.');
      await tester.pumpAndSettle();
      ////////////////////////////
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      ///////////////////////////

      // Trigger the Date Picker
      await tester.tap(find.byKey(const Key('EventDateField')));
      await tester.pumpAndSettle();
      // Navigate to after 3 months by tapping "Next month" 3 times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Next month'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('15')); // Select the 15th day of the month
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Trigger the Time Picker
      await tester.tap(find.byKey(const Key('EventTimeField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Confirm the time
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('PrivateSwitch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('AddEvent'))); // Save the event
      await tester.pumpAndSettle();

      // Wait for Navigation back to EventsPage
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify the event is listed on the EventsPage
      expect(find.text('Public Event'), findsOneWidget);

      /// Adding a Gift to the Event ///
      // Tap on the event to view details
      await tester.tap(find.text('Public Event'));
      await tester.pumpAndSettle();

      // Tap the add gift button
      await tester.tap(find.byKey(const Key('AddGiftButton')));
      await tester.pumpAndSettle();

      // Enter gift details
      await tester.enterText(find.byKey(const Key('GiftTitleField')), 'Samsung S23');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('GiftDescriptionField')), 'A special birthday gift with 256GB.');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('GiftPriceField')), '20000');
      await tester.pumpAndSettle();

      // Save the gift
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('SaveGiftButton')));
      await tester.pumpAndSettle();

      // Verify the gift is listed for the event
      expect(find.text('Samsung S23'), findsOneWidget);
    });
    testWidgets('Sign in with different account and pledge the previous Test', (WidgetTester tester) async{

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

    /// Sign in different account ///
    await tester.enterText(find.byKey(const Key('emailField')), 'tamer@gmail.com');
    await tester.pumpAndSettle(); // Ensure text is entered
    await tester.enterText(find.byKey(const Key('passwordField')), '12345678');
    await tester.pumpAndSettle(); // Ensure text is entered
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('signInButton')));
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle(); // Ensure button is tapped and response is processed

    await Future.delayed(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));

    // Refresh
    await tester.ensureVisible(find.byType(RefreshIndicator));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 200));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 10));

    /// Pledge a Gift ///
    await tester.tap(find.text('Rafik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Public Event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pledge'));
    await tester.pumpAndSettle();

    expect(find.text('Pledge'), findsNothing);
  });
  });
}
