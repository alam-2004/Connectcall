import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/call_model.dart';

class CallingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  Stream<List<CallModel>> getCallHistory(String userId) {
    return _calls
        .where(
          Filter.or(
            Filter('callerId', isEqualTo: userId),
            Filter('receiverId', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) {
          final calls = snapshot.docs
              .map((doc) => CallModel.fromFirestore(doc))
              .toList();

          calls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return calls;
        });
  }

  Future<void> updateCallStatus(String callId, CallStatus status) async {
    await _calls.doc(callId).update({'status': status.name});
  }

  Future<void> updateCallDuration(String callId, int duration) async {
    await _calls.doc(callId).update({'duration': duration});
  }
}
