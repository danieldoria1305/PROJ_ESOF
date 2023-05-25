import 'package:GenealogyGuru/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  final User? user;

  MockUserCredential({this.user});
}

void stubSignInWithEmailAndPassword(MockFirebaseAuth mockFirebaseAuth, MockUserCredential mockUserCredential) {

}

void main() {
  group('LoginScreen', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late LoginScreen loginScreen;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential(user: mockUser);
      loginScreen = LoginScreen(showRegisterScreen: () {}, auth: mockFirebaseAuth);
    });

    testWidgets('Login success', (WidgetTester tester) async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email', that: isNotNull),
          password: any(named: 'password', that: isNotNull)))
          .thenAnswer((_) {
        return Future.value(mockUserCredential);
      });

      // Provide the mockFirebaseAuth instance to the FirebaseAuth class
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: loginScreen,
          ),
        ),
      );

      // Enter email and password
      await tester.enterText(find.byKey(Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('PasswordField')), 'password');

      // Tap the sign-in button
      await tester.tap(find.byKey(Key('SignInButton')));
      await tester.pumpAndSettle();

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);

      // Verify that the dialog is dismissed
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Login failure', (WidgetTester tester) async {
      // Stub the sign-in method to throw an exception
      final exception = FirebaseAuthException(
        code: 'invalid-email',
        message: 'Invalid email address',
      );
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).thenThrow(exception);

      // Provide the mockFirebaseAuth instance to the FirebaseAuth class
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: loginScreen,
          ),
        ),
      );

      // Enter email and password
      await tester.enterText(find.byKey(Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('PasswordField')), 'password');

      // Tap the sign-in button
      await tester.tap(find.byKey(Key('SignInButton')));
      await tester.pumpAndSettle();

      // Verify that sign-in method was called with the correct credentials
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);

      // Verify that the error dialog is shown
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid email address'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
