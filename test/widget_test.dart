// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nselectrical/src/app.dart';
import 'package:nselectrical/src/core/services/auth_service.dart';
import 'package:nselectrical/src/core/providers/theme_provider.dart';
import 'package:nselectrical/src/core/providers/language_provider.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Create a mock auth service for testing
    final authService = AuthService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ],
        child: MyApp(authService: authService),
      ),
    );

    // Verify that the splash screen is displayed.
    expect(find.text('NS Electrical'), findsOneWidget);
  });
}