import 'package:SurbaMart/components/auth.dart';
import 'package:flutter/material.dart';
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
                          ElevatedButton(
                            onPressed: () => _handleResetPassword(context),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('Reset Password'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Added space between the card and the button
                TextButton(
                  onPressed: () {
                    // Navigate to the login screen or any other screen
                    Navigator.pop(context);
                  },

                  child: Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
