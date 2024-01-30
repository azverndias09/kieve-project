import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopper_app/admin/adminHome.dart';
import 'package:shopper_app/components/auth.dart';
import 'package:shopper_app/user/home.dart';
import 'package:shopper_app/register.dart';
import 'package:shopper_app/reset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = ''; // Variable to hold error messages

  // Function to handle the login button press
  // Function to handle the login button press
  // Function to handle the login button press
  Future<void> _handleLogin() async {
    try {
      // Check if there's a stored user
      User? storedUser = await _authService.getStoredUser();
      if (storedUser != null) {
        // User is already logged in, redirect to the appropriate page
        // Use the isAdmin check if needed
        // Replace the line below with your actual home page navigation logic
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(storedUser.uid)
            .get();

        bool isAdmin = userSnapshot['isAdmin'] ?? false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => isAdmin ? AdminHomePage() : UserHomePage()),
        );
        return;
      }

      // Continue with the login process if there's no stored user
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential? userCredential =
            await _authService.signInWithEmailAndPassword(email, password);

        // Reset error message on successful login
        setState(() {
          _errorMessage = '';
        });

        if (userCredential!.user != null) {
          // Fetch user data from Firestore
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          bool isAdmin = userSnapshot['isAdmin'] ?? false;

          // Store user information in SharedPreferences
          await _authService.storeUserInfoLocally(userCredential.user);

          Fluttertoast.showToast(
            msg: isAdmin ? "Admin Login Successful!" : "User Login Successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          if (isAdmin) {
            // Redirect to admin homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()),
            );
            print("Admin Login successful!");
          } else {
            // Redirect to user homepage

            print(
                "User Login successful! User ID: ${userCredential.user!.uid}");
          }
        }
      } else {
        // Handle invalid input
        setState(() {
          _errorMessage = 'Please enter both email and password.';
        });

        Fluttertoast.showToast(
          msg: _errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred.';
      });

      Fluttertoast.showToast(
        msg: _errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });

      Fluttertoast.showToast(
        msg: _errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print("An unexpected error occurred: $e");
    }
  }

  // Function to handle the "Forgot Password" button press
  Future<void> _handleForgotPassword() async {
    String email = _emailController.text.trim();

    // Navigate to the ResetPasswordScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: _handleForgotPassword,
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 8.0),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('No account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
