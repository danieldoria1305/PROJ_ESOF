import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegisterScreen({Key? key, required this.showLoginScreen}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
  
  bool passwordConfirmed() {
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Passwords do not match"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          }
      );
      return false;
    }
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(e.toString().split(']').last.trim()),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }
        );
      }
      addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          int.parse(_ageController.text.trim()),
      );
    }
  }

  Future addUserDetails(String firstName, String lastName, String email, int age) async {
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "age": age,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    Text(
                      "Hello There",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 52,
                        color: Colors.brown[700],
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: TextField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown.shade700),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: 'First Name',
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                ),
                              )
                          ),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: TextField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown.shade700),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  hintText: 'Last Name',
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: TextField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.brown.shade700),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Age',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.brown.shade700),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Email',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.brown.shade700),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Password',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                          obscureText: true,
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.brown.shade700),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Confirm Password',
                            fillColor: Colors.grey[200],
                            filled: true,
                          ),
                          obscureText: true,
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                        onTap: signUp,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.brown[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already a member?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),),
                        GestureDetector(
                          onTap: widget.showLoginScreen,
                          child: Text(" Login here",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }
}
