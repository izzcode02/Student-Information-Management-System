import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageFunction {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  // Add a new message
  Future<void> addMessage({
    required String message,
  }) async {
    try {
      await _firestore.collection('notes').add({
        'userId': user?.uid,
        'message': message,
        'deleted': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding message: $e');
      rethrow;
    }
  }

  // Delete a single message
  Future<void> deleteMessage(String documentId) async {
    try {
      await _firestore
          .collection('notes')
          .doc(documentId)
          .update({'deleted': true});
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  // Clear all messages for a user
  Future<void> clearMessages() async {
    try {
      var snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user?.uid)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'deleted': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing messages: $e');
      rethrow;
    }
  }

  // Stream of messages for a specific user
  Stream<QuerySnapshot> getMessages() {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: user?.uid)
        .where('deleted', isEqualTo: false)
        .snapshots();
  }

  // Get deleted messages
  Stream<QuerySnapshot> getDeletedMessages() {
    return _firestore
        .collection('notes')
        .where('deleted', isEqualTo: true)
        .snapshots();
  }

  // Restore message
  Future<void> restoreMessage(String documentId) async {
    try {
      await _firestore
          .collection('notes')
          .doc(documentId)
          .update({'deleted': false});
    } catch (e) {
      print('Error restoring message: $e');
      rethrow;
    }
  }

  // Permanent delete message
  Future<void> permanentDeleteMessage(String documentId) async {
    try {
      await _firestore.collection('notes').doc(documentId).delete();
    } catch (e) {
      print('Error permanently deleting message: $e');
      rethrow;
    }
  }
}
