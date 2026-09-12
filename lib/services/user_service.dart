import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).set({
      'isOnline': isOnline,
    }, SetOptions(merge: true));
  }

  Stream<List<UserModel>> getUsers(String currentUserId) {
    return _firestore.collection(AppConstants.usersCollection).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {}
}
