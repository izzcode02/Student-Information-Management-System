import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/register_service.dart';

class StudentProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final registerService = RegisterService();

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
// Store customUid here

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;

  Future<void> fetchProfileData() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Query the collection to find the document matching the logged-in user's email
        final querySnapshot = await _firestore
            .collection("Student")
            .where("email", isEqualTo: user.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _profileData = querySnapshot.docs.first.data();
          print("Profile Data: $_profileData");
        } else {
          print("No matching user found in Firestore.");
        }
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileData({
    required String semester,
    required String courseCode,
    required String courseName,
    required String facultyName,
    required String enrollmentStatus,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user?.uid != null) {
        // Update the fields in the document using the customUid
        await _firestore.collection("Student").doc(user?.uid).update({
          'semester': semester,
          'course code': courseCode,
          'course name': courseName,
          'faculty name': facultyName,
          'enrollment status': enrollmentStatus,
        });

        print("Profile updated successfully.");
      } else {
        print("Custom UID not found. Fetch profile data first.");
      }
    } catch (e) {
      print("Error updating profile data: $e");
    }
  }
}
