import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;

      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        isOnline: true,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user!;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .update({'isOnline': true});

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'isOnline': false});
    }

    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return UserModel.fromMap(snapshot.data()!);
  }
}
