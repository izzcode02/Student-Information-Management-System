import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lab2_app/controller/auth.dart';

class RegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService service = AuthService();

  Future<bool> registerStudent(
      String fullname,
      String email,
      String password,
      String role,
      String courseName,
      String courseCode,
      String facultyName,
      String semester,
      String enrollment,
      BuildContext context) async {
    try {
      //Generate unique uid such as UID001, UID002
      String customUid = await getNextStuid();

      // Register user in Firebase Authentication
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;

      // // Optional: Set display name
      // await user.updateDisplayName(fullname);

      // Store additional user information in Firestore
      await _firestore.collection('Student').doc(user.uid).set({
        'uid': customUid,
        'full name': fullname,
        'email': email,
        'role': role,
        'course name': courseName,
        'course code': courseCode,
        'faculty name': facultyName,
        'semester': semester,
        'enrollment status': enrollment,
        'authUid': user
            .uid, // Link Firebase Auth UID to custom UID for avoid user tempering
      });

      // Optionally: Show success message (not needed if returning true)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Colors.green,
        ),
      );

      return true; // Registration successful
    } catch (e) {
      print("Registration failed: ${e.toString()}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      return false; // Registration failed
    }
  }

  // Generate the next UID with auto-increment logic
  Future<String> getNextStuid() async {
    try {
      // Reference the counter document in Firestore
      DocumentReference counterRef =
          _firestore.collection('Counters').doc('Student');

      // Perform a transaction to increment the counter
      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

        int currentCount = 0;

        // If the document exists, get the current counter value
        if (counterSnapshot.exists) {
          currentCount = counterSnapshot.get('current') as int;
        }

        // Increment the counter
        int nextCount = currentCount + 1;

        // Update the counter value in Firestore
        transaction.set(
          counterRef,
          {'current': nextCount},
          SetOptions(merge: true),
        );

        // Generate the UID in the desired format
        return 'StuID${nextCount.toString().padLeft(3, '0')}'; // e.g., UID001, UID002
      });
    } catch (e) {
      throw Exception("Failed to generate UID: $e");
    }
  }

  Future<void> deleteUser() async {
    try {
      // Get the current user
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user is currently logged in.');
      }

      // Delete the user document from Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .delete();
      print('User document deleted from Firestore.');
      // Delete the user document from Firestore

      await user.delete();
      // Delete the user from Firebase Authentication
      if (user.delete() == true) {
        _auth.signOut;
      }

      print('User account deleted successfully.');
    } catch (e) {
      print('Error deleting user: $e');
      // Handle specific errors (e.g., reauthentication required)
    }
  }
}
