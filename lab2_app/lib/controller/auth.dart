import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/navigator.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = auth.currentUser;
    if (user == null) {
      return null; // No user is currently signed in
    }

    try {
      final studentDoc = await firestore
          .collection('Student')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (studentDoc.docs.isNotEmpty) {
        final studentData = studentDoc.docs.first.data();
        return {
          'email': studentData['email'],
          'role': studentData['role'],
        };
      } else {
        return null; // User document not found in Firestore
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<dynamic> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Check if user is not null
        toNavigate.gotoStudent(context); // Navigate after successful sign-in
        return userCredential.user; // Return the user
      } else {
        // Handle the case where user is null after credential sign in (rare but possible)
        print("Error: User is null after successful credential sign-in.");
        return null;
      }
    } on Exception catch (e) {
      // TODO
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future signIn(String email, String password, BuildContext context) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch the user role from Firestore
      await _navigateBasedOnRole(userCredential.user, context);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('User not found, please try again.')));
          break;
        case 'wrong-password':
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Wrong password, please try again.')));
          break;
        case 'network-request-failed':
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No internet connection.')));
          throw Exception('No internet connection');
        default:
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error occurred: ${error.message}')));
          throw Exception('Error occurred: ${error.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _navigateBasedOnRole(User? user, BuildContext context) async {
    if (user == null) return;

    try {
      // Query the Firestore Student collection
      final studentDoc = await FirebaseFirestore.instance
          .collection('Student')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (studentDoc.docs.isNotEmpty) {
        // Navigate to Student screen if role is Student
        final role = studentDoc.docs.first['role'];
        if (role == 'Student') {
          toNavigate.gotoStudent(context);
        } else {
          // Unknown role for Student collection
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Unknown role in Student collection.')),
          // );
        }
        return;
      }

      // Query the Firestore Staff collection if not found in Student
      final staffDoc = await FirebaseFirestore.instance
          .collection('Staff')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (staffDoc.docs.isNotEmpty) {
        // Navigate to Staff screen if role is Staff
        final role = staffDoc.docs.first['role'];
        if (role == 'Staff') {
          toNavigate.goToStaff(context);
        } else {
          // Unknown role for Staff collection
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Unknown role in Staff collection.')),
          // );
        }
        return;
      }

      // // User not found in either collection
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('User role not found in Firestore.')),
      // );
    } catch (e) {
      // Handle Firestore access errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing Firestore: ${e.toString()}')),
      );
    }
  }

  Future<void> currentUserScreen(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _navigateBasedOnRole(user, context);
    }
  }

  Future signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await auth.signOut();
      toNavigate.gotoLogin(context);
    } catch (e) {
      print(e);
    }
  }
}
