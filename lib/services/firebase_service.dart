import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../models/declutter_item.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // User operations
  static Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error saving user: $e');
      throw e;
    }
  }

  static Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  // Declutter item operations
  static Future<void> saveDeclutterItem(DeclutterItem item, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('declutter_items')
          .doc(item.id)
          .set(item.toJson());
    } catch (e) {
      print('Error saving declutter item: $e');
      throw e;
    }
  }

  static Future<List<DeclutterItem>> getDeclutterItems(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('declutter_items')
          .get();
      
      return querySnapshot.docs
          .map((doc) => DeclutterItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting declutter items: $e');
      return [];
    }
  }

  static Future<void> updateDeclutterItem(DeclutterItem item, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('declutter_items')
          .doc(item.id)
          .update(item.toJson());
    } catch (e) {
      print('Error updating declutter item: $e');
      throw e;
    }
  }

  static Future<void> deleteDeclutterItem(String itemId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('declutter_items')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting declutter item: $e');
      throw e;
    }
  }

  // Authentication
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
