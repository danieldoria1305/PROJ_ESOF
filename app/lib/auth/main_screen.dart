import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:GenealogyGuru/screens/home_screen.dart';
import 'auth_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen(title: 'GenealogyGuru');
          } else {
            return AuthScreen();
          }


        }
      )
    );
  }
}