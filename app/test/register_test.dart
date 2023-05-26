import 'package:GenealogyGuru/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  final User user;

  MockUserCredential({required this.user});
}


void main() {
  group('RegisterScreen', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late RegisterScreen registerScreen;

    setUpAll(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential(user: mockUser);
      registerScreen = RegisterScreen(showLoginScreen: () {}, auth: mockFirebaseAuth);
    });

    testWidgets('Register success', (WidgetTester tester) async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email', that: isNotNull),
          password: any(named: 'password', that: isNotNull)))
          .thenAnswer((_) {
        return Future.value(mockUserCredential);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: registerScreen,
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('FirstNameField')), 'Test');
      await tester.enterText(find.byKey(const Key('LastNameField')), 'One');
      await tester.enterText(find.byKey(const Key('AgeField')), '20');
      await tester.enterText(find.byKey(const Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('PasswordField')), 'password');
      await tester.enterText(find.byKey(const Key('ConfirmPasswordField')), 'password');

      await tester.tap(find.byKey(const Key('SignUpButton')));
      await tester.pumpAndSettle();

      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Register failure', (WidgetTester tester) async {
      final exception = FirebaseAuthException(
        code: 'invalid-password',
        message: 'Invalid password',
      );
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).thenThrow(exception);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: registerScreen,
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('FirstNameField')), 'Test');
      await tester.enterText(find.byKey(const Key('LastNameField')), 'One');
      await tester.enterText(find.byKey(const Key('AgeField')), '20');
      await tester.enterText(find.byKey(const Key('EmailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('PasswordField')), 'password');
      await tester.enterText(find.byKey(const Key('ConfirmPasswordField')), 'password');

      await tester.tap(find.byKey(const Key('SignUpButton')));
      await tester.pumpAndSettle();

      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email', that: isNotNull),
        password: any(named: 'password', that: isNotNull),
      )).called(1);


      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid password'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
