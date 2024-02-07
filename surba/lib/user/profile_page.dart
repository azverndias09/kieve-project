import 'package:SurbaMart/components/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch user information and set the initial values in the text controllers
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // Fetch user information and set the initial values in the text controllers
    AuthService authService = AuthService();
    User? user = await authService.getStoredUser();

    if (user != null) {
      // Fetch additional user data from Firestore
      // Replace 'your_user_id_field' with the actual field in your user document
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _firstNameController.text = userSnapshot.get('firstName') ?? '';
        _lastNameController.text = userSnapshot.get('lastName') ?? '';
        _phoneNumberController.text = userSnapshot.get('phoneNumber') ?? '';
      });
    }
  }

  Future<void> _updateUserInfo() async {
    AuthService authService = AuthService();
    User? user = await authService.getStoredUser();

    if (user != null) {
      try {
        // Update user information in Firestore
        await FirestoreService().updateUserInfo(
          user.uid,
          _firstNameController.text,
          _lastNameController.text,
          _phoneNumberController.text,
        );

        // Reload user information after update
        await _loadUserInfo();

        // Show a success message or perform any additional actions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User information updated successfully!')),
        );
      } catch (e) {
        // Handle errors, show an error message or perform any additional actions
        print('Error updating user information: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user information.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
