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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
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
                    Image.asset(
                      "assets/app_icon.png",
                      width: 200,
                      height: 200,
                    ),
                    SizedBox(height: 25),
                    Text(
                      "Hello There",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 52,
                        color: Colors.brown[700],
                      ),
                    ),
                    SizedBox(height: 40),
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
