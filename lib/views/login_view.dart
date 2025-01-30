import 'package:flutter/material.dart';
import 'package:kavruk/constants/routers.dart';
import 'package:kavruk/user/auth_exception.dart';
import 'dart:developer' as devtools show log;

import 'package:kavruk/user/auth_service.dart';
import 'package:kavruk/utilities/error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _isAdditionalInfoComplete(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.exists && userDoc.data()?['userName'] != null;
    } catch (e) {
      devtools.log('Error checking additional info: $e');
      return false; // Assume incomplete if error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Coverook.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Spacer to push content lower
                    const SizedBox(
                        height:
                            300), // Adjust this value for more or less space

                    // Email Field
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Password Field
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          // Your authentication logic
                          await AuthService.firebase().logIn(email, password);
                          final user = AuthService.firebase().currentUser;

                          if (user?.isEmailVerified ?? false) {
                            final userId = user?.id;

                            // Check if additional info is complete
                            if (userId != null) {
                              final isComplete =
                                  await _isAdditionalInfoComplete(userId);
                              if (!isComplete) {
                                // Navigate to AdditionalInfoView
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  additionalInfoRoute,
                                  (context) => false,
                                  arguments: userId,
                                );
                              } else {
                                // Navigate to the homepage
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  homepageRoute,
                                  (route) => false,
                                );
                              }
                            }
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                verifyEmailRoute, (context) => false);
                          }
                        } on UserNotFoundException {
                          await showErrorDialog(context, 'User not found');
                        } on WrongPasswordException {
                          await showErrorDialog(context, 'Wrong password');
                        } on GenericAuthException {
                          await showErrorDialog(
                              context, 'Authentication failed');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 126, 62, 38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 16 , color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Register Link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                      child: const Text(
                        'Not registered yet? Register here!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
