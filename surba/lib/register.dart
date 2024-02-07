import 'package:SurbaMart/components/auth.dart';
import 'package:SurbaMart/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SurbaMart/user/user_details.dart'; // Import Firestore

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();
  bool _isAdmin = false;

  String _errorText = ''; // Error message text

  // Function to handle the register button press
  Future<void> _handleRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String adminCode = _adminCodeController.text.trim();

    setState(() {
      _errorText = ''; // Reset error message
    });

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      // Display an error message for empty fields
      setState(() {
        _errorText = 'Please enter both email and password.';
      });
      return;
    }

    if (password != confirmPassword) {
      // Display an error message for password mismatch
      setState(() {
        _errorText = 'Passwords do not match.';
      });
      return;
    }

    if (_isAdmin) {
      // Check Admin Code from Firestore
      bool isAdminCodeValid = await _checkAdminCode(adminCode);

      if (!isAdminCodeValid) {
        // Display an error message or handle invalid Admin Code
        setState(() {
          _errorText = 'Invalid Admin Code.';
        });
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
      setState(() {
        _errorText = 'Registration failed: $e';
      });
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/blue.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white60.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 400.0, // Set your desired width
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.6),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 20.0, // Increase vertical padding
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.6),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 20.0, // Increase vertical padding
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.6),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 20.0, // Increase vertical padding
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0), // Reduced spacing here
                          if (_isAdmin)
                            TextField(
                              controller: _adminCodeController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Admin Code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.6),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 20.0, // Increase vertical padding
                                ),
                              ),
                            ),
                          SizedBox(height: 10.0), // Reduced spacing here
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
                              SizedBox(width: 8.0), // Reduced spacing here
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
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () async {
                              await _handleRegister();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('Register'),
                          ),
                          SizedBox(height: 8.0),
                          if (_errorText.isNotEmpty)
                            Text(
                              _errorText,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Added space between the card and the button
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
        ),
      ),
    );
  }

}
