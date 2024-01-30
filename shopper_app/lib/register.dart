import 'package:flutter/material.dart';
import 'package:shopper_app/components/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopper_app/login.dart';
import 'package:shopper_app/user/user_details.dart'; // Import Firestore

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController =
      TextEditingController(); // Add Admin Code controller
  bool _isAdmin = false;

  // Function to handle the register button press
  Future<void> _handleRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String adminCode = _adminCodeController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      if (_isAdmin) {
        // Check Admin Code from Firestore
        bool isAdminCodeValid = await _checkAdminCode(adminCode);

        if (!isAdminCodeValid) {
          // Display an error message or handle invalid Admin Code
          print("Invalid Admin Code");
          return;
        }
      }

      try {
        // Call the sign-up method from AuthService
        await _authService.signUpWithEmailAndPassword(
          email,
          password,
          _isAdmin,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserInfoPage()),
        );
      } catch (e) {
        // Handle registration failure, e.g., display an error message
        print("Registration failed: $e");
      }
    } else {
      // Handle invalid input (show an error message, etc.)
      print("Please enter both email and password.");
    }
  }

  // Method to check Admin Code from Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Screen'),
      ),
      body: Padding(
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
            if (_isAdmin) // Show Admin Code field only if registering as admin
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
              onPressed: _handleRegister,
              child: Text('Register'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Already registered? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}
