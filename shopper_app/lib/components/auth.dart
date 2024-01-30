import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopper_app/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> storeUserInfoLocally(User? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userUid', user?.uid ?? '');
    // Add more user information as needed
  }

  Future<User?> getStoredUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userUid = prefs.getString('userUid') ?? '';
    // Retrieve more user information as needed
    // Check if userUid is not empty before fetching user data
    if (userUid.isNotEmpty) {
      return _auth.currentUser;
    } else {
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
      rethrow; // Rethrow the exception to handle it in the UI
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword(
      String email, String password, bool isAdmin) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await storeUserInfoLocally(userCredential.user);
      // Create user document in Firestore with additional data (role)
      await _firestoreService.createUserDocument(
        userCredential.user!.uid,
        email,
        isAdmin,
      );
    } catch (e) {
      print("Error in sign up: $e");
      rethrow; // Rethrow the exception to handle it in the UI
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Error in sign in: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
      rethrow; // Rethrow the exception to handle it in the UI
    }
  }

  Future<void> clearStoredUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userUid');
    // Remove more user information as needed
  }

  Future<void> logout(BuildContext context) async {
    // Sign out the user
    await signOut();

    // Remove stored user information
    await clearStoredUserInfo();

    // Navigate back to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ); // Replace with your login route
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateUserInfo(
      String uid, String firstName, String lastName, String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      print('Error updating user info: $e');
    }
  }

  Future<void> createUserDocument(
      String uid, String email, bool isAdmin) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'isAdmin': isAdmin,
    });
  }

  // Add other Firestore methods here
}
