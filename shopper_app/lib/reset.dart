import 'package:flutter/material.dart';
import 'package:shopper_app/components/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _handleResetPassword(BuildContext context) async {
    String email = _emailController.text.trim();

    if (email.isNotEmpty) {
      try {
        // Call the resetPassword method from AuthService
        await _authService.resetPassword(email);

        // Show a success toast message
        Fluttertoast.showToast(
          msg: "Password reset email sent. Check your inbox.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Optionally, navigate the user back to the login screen or any other screen
        Navigator.pop(context);
      } catch (e) {
        // Handle specific errors if needed
        print("Error handling password reset: $e");

        // Show an error toast message
        Fluttertoast.showToast(
          msg: "Error sending password reset email. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // Handle invalid input (show an error message, etc.)
      Fluttertoast.showToast(
        msg: "Please enter your email to reset the password.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _handleResetPassword(context),
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
