import 'dart:core';
import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenealogyGuru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(),// const HomeScreen(title: 'GenealogyGuru'),
    );
  }
}

