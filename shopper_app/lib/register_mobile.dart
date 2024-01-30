import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:shopper_app/components/auth.dart';
import 'package:shopper_app/login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();
  bool _isAdmin = false;
  late final AuthService authService;
  @override
  void initState() {
    super.initState();
    authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Screen'),
      ),
      body: FirebasePhoneAuthHandler(
        phoneNumber: "+919876543210", // Replace with your phone number logic
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(height: 16.0),
                if (_isAdmin)
                  TextField(
                    controller: _adminCodeController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Admin Code'),
                  ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Radio(
                      value: false,
                      groupValue: _isAdmin,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAdmin = value!;
                        });
                      },
                    ),
                    Text('User'),
                    SizedBox(width: 16.0),
                    Radio(
                      value: true,
                      groupValue: _isAdmin,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAdmin = value!;
                        });
                      },
                    ),
                    Text('Admin'),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    String adminCode = _adminCodeController.text.trim();

                    if (email.isNotEmpty && password.isNotEmpty) {
                      if (_isAdmin) {
                        bool isAdminCodeValid =
                            await _checkAdminCode(adminCode);

                        if (!isAdminCodeValid) {
                          print("Invalid Admin Code");
                          return;
                        }
                      }

                      try {
                        await authService.signUpWithEmailAndPassword(
                          email,
                          password,
                          _isAdmin,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      } catch (e) {
                        print("Registration failed: $e");
                      }
                    } else {
                      print("Please enter both email and password.");
                    }
                  },
                  child: Text('Register'),
                ),
                SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Already registered? Login here'),
                ),
              ],
            ),
          );
        },
        onLoginSuccess: (userCredential, autoVerified) {
          debugPrint("Login success UID: ${userCredential.user?.uid}");
        },
        onLoginFailed: (authException, stackTrace) {
          debugPrint("An error occurred: ${authException.message}");
        },
      ),
    );
  }

  Future<bool> _checkAdminCode(String enteredCode) async {
    try {
      // Fetch the Admin Code from Firestore
      DocumentSnapshot adminCodeSnapshot = await FirebaseFirestore.instance
          .collection('adminCode')
          .doc('UtUPmdnDEUvWihrCZOXX')
          .get();

      // Compare the entered code with the one from Firestore
      String correctAdminCode = adminCodeSnapshot['code'] ?? '';
      return enteredCode == correctAdminCode;
    } catch (e) {
      // Handle errors, e.g., log the error
      print('Error checking Admin Code: $e');
      return false;
    }
  }
}
