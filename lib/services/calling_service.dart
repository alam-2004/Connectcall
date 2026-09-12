import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';

class CallingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create call record
  Future<CallModel> createCall({
    required UserModel caller,
    required UserModel receiver,
    required CallType type,
  }) async {
    final docRef = _firestore.collection(AppConstants.callsCollection).doc();

    final call = CallModel(
      id: docRef.id,
      callerId: caller.uid,
      callerName: caller.name,
      receiverId: receiver.uid,
      receiverName: receiver.name,
      type: type,
      status: CallStatus.calling,
      createdAt: DateTime.now(),
      duration: 0,
    );

    await docRef.set(call.toMap());

    return call;
  }

  /// Update call status
  Future<void> updateCallStatus({
    required String callId,
    required CallStatus status,
  }) async {
    await _firestore
        .collection(AppConstants.callsCollection)
        .doc(callId)
        .update({'status': status.name});
  }

  /// Accept / Connect call
  Future<void> connectCall(String callId) async {
    await updateCallStatus(callId: callId, status: CallStatus.connected);
  }

  /// End call
  Future<void> endCall({required String callId, required int duration}) async {
    await _firestore
        .collection(AppConstants.callsCollection)
        .doc(callId)
        .update({
          'status': CallStatus.ended.name,
          'endedAt': FieldValue.serverTimestamp(),
          'duration': duration,
        });
  }

  /// Reject call
  Future<void> rejectCall(String callId) async {
    await updateCallStatus(callId: callId, status: CallStatus.rejected);
  }

  /// Mark missed call
  Future<void> markMissedCall(String callId) async {
    await updateCallStatus(callId: callId, status: CallStatus.missed);
  }

  /// Listen to one call
  Stream<CallModel?> listenToCall(String callId) {
    return _firestore
        .collection(AppConstants.callsCollection)
        .doc(callId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }

          return CallModel.fromFirestore(snapshot);
        });
  }

  /// Listen for incoming calls
  Stream<List<CallModel>> listenToIncomingCalls(String userId) {
    return _firestore
        .collection(AppConstants.callsCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.calling.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CallModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get call history
  Stream<List<CallModel>> getCallHistory(String userId) {
    return _firestore.collection(AppConstants.callsCollection).snapshots().map((
      snapshot,
    ) {
      final calls = snapshot.docs
          .map((doc) => CallModel.fromFirestore(doc))
          .where((call) => call.callerId == userId || call.receiverId == userId)
          .toList();

      calls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return calls;
    });
  }
}
