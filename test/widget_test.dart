import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('Router Tests', () {
    testWidgets('App starts at PollPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('PollPage'), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses correct primary swatch and Google Fonts', (tester) async {
      await tester.pumpWidget(const App());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = app.theme;

      expect(theme?.primaryColor, equals(Colors.deepPurple));

      final textTheme = theme?.textTheme;
      final robotoFont = GoogleFonts.robotoTextTheme();
      expect(textTheme?.bodyLarge?.fontFamily, robotoFont.bodyLarge?.fontFamily);
    });
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

