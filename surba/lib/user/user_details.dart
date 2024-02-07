import 'package:SurbaMart/components/auth.dart';
import 'package:SurbaMart/login.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';


class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _saveUserInfo() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String firstName = _firstNameController.text.trim();
        String lastName = _lastNameController.text.trim();
        String phoneNumber = _phoneNumberController.text.trim();

        // Validate user input
        if (firstName.isNotEmpty &&
            lastName.isNotEmpty &&
            phoneNumber.isNotEmpty) {
          await _firestoreService.updateUserInfo(
            user.uid,
            firstName,
            lastName,
            phoneNumber,
          );

          // Navigate to the main/home page (replace with your main page)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // Handle invalid input (show an error message, etc.)
          print("Please enter all required information.");
        }
      }
    } catch (e) {
      print("Error saving user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveUserInfo,
              child: Text('Save Information'),
            ),
          ],
        ),
      ),
    );
  }
}
