import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:env_assignment/screens/home/complaints_dept.dart';
import 'package:env_assignment/screens/home/complaints_public.dart';
import 'package:env_assignment/screens/auth/register.dart';
import 'package:env_assignment/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/complaints.dart';
import '../home/complaints_beat.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/loginscreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Future<String> _getUserType(String userId) async {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.get('type') ?? 'public';
      }

      return 'public'; // Default to 'user' if not found
    }

    void _navigateToHomeScreen(String userType) {
      switch (userType) {
        case 'admin':
          Navigator.pushReplacementNamed(context, ComplaintsScreen.routeName);
          break;
        case 'forest':
          Navigator.pushReplacementNamed(context, ComplaintsDept.routeName);
          break;
        case 'wild':
          Navigator.pushReplacementNamed(context, ComplaintsDept.routeName);
          break;
        case 'public':
          Navigator.pushReplacementNamed(context, ComplaintsPublic.routeName);
          break;
        case 'beat':
          Navigator.pushReplacementNamed(context, ComplaintsBeat.routeName);
          break;
        default:
          // Handle unknown user type
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),

              // Login button
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim().toLowerCase();
                  String password = _passwordController.text.trim();

                  if (email.isNotEmpty && password.isNotEmpty) {
                    User? user = await _authService.signInWithEmailAndPassword(
                        email, password);

                    if (user != null) {
                      String userType = await _getUserType(user.uid);

                      // Navigate based on user type
                      _navigateToHomeScreen(userType);
                    } else {
                      print('Login failed');
                    }
                  } else {
                    print('Email and password are required');
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: const Text('Login'),
                ),
              ),

              const SizedBox(height: 16.0),

              // Redirect to Register button
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.routeName);
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
