import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:GenealogyGuru/screens/login_screen.dart';
import 'package:GenealogyGuru/screens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLoginScreen = true;

  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen(showRegisterScreen: toggleScreens, auth: FirebaseAuth.instance,);
    } else {
      return RegisterScreen(showLoginScreen: toggleScreens, auth: FirebaseAuth.instance);
    }
  }
}