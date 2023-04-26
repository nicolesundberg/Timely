import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timely/widgets/notification_bell.dart';
import 'package:flutter/material.dart';


class MockFunction extends Mock {
  void call();
}

/// Testing for NotificationBell
void main() {
  testWidgets('NotificationBell appears', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NotificationBell(func: MockFunction()))));
    final bellFinder = find.byIcon(Icons.notifications_active);
    expect(bellFinder, findsOneWidget);
  });

  testWidgets('Clicking on NotificationBell calls function once', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    MockFunction mockedFunction = MockFunction();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NotificationBell(func: mockedFunction))));
    final bellFinder = find.byIcon(Icons.notifications_active);
    expect(bellFinder, findsOneWidget);
    await tester.tap(bellFinder);
    verify(mockedFunction.call()).called(1);
  });
}
