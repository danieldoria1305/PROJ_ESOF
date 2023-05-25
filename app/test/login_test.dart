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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: loginScreen,
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('PasswordField')), 'password');

      await tester.tap(find.byKey(const Key('SignInButton')));
      await tester.pumpAndSettle();

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Login failure', (WidgetTester tester) async {
      final exception = FirebaseAuthException(
        code: 'invalid-email',
        message: 'Invalid email address',
      );
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).thenThrow(exception);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: loginScreen,
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('PasswordField')), 'password');

      await tester.tap(find.byKey(const Key('SignInButton')));
      await tester.pumpAndSettle();

      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid email address'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
