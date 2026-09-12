import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/call_model.dart';

class CallProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _incomingSubscription;

  CallModel? _currentCall;

  bool _isMuted = false;
  bool _isCameraOn = true;

  Timer? _timer;
  int _durationSeconds = 0;

  CallModel? get currentCall => _currentCall;

  bool get isMuted => _isMuted;

  bool get isCameraOn => _isCameraOn;

  int get durationSeconds => _durationSeconds;

  void listenForIncomingCalls(String userId) {
    _incomingSubscription?.cancel();

    _incomingSubscription = _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'calling')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            _currentCall = null;
          } else {
            _currentCall = CallModel.fromFirestore(snapshot.docs.first);
          }

          notifyListeners();
        });
  }

  Future<CallModel> startCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required CallType type,
  }) async {
    final doc = _firestore.collection('calls').doc();

    final call = CallModel(
      id: doc.id,
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      type: type,
      status: CallStatus.calling,
      createdAt: DateTime.now(),
    );

    await doc.set(call.toMap());

    _currentCall = call;

    notifyListeners();

    return call;
  }

  Future<void> connectCall() async {
    if (_currentCall == null) return;

    await _firestore.collection('calls').doc(_currentCall!.id).update({
      'status': CallStatus.connected.name,
    });

    _currentCall = _currentCall!.copyWith(status: CallStatus.connected);

    _startTimer();

    notifyListeners();
  }

  Future<void> acceptCall(CallModel call) async {
    await _firestore.collection('calls').doc(call.id).update({
      'status': CallStatus.connected.name,
    });

    _currentCall = call.copyWith(status: CallStatus.connected);

    _startTimer();

    notifyListeners();
  }

  Future<void> rejectCurrentCall() async {
    if (_currentCall == null) return;

    await _firestore.collection('calls').doc(_currentCall!.id).update({
      'status': CallStatus.rejected.name,
    });

    _stopTimer();

    _currentCall = null;

    notifyListeners();
  }

  Future<void> endCurrentCall() async {
    if (_currentCall == null) return;

    await _firestore.collection('calls').doc(_currentCall!.id).update({
      'status': CallStatus.ended.name,
      'duration': _durationSeconds,
    });

    _stopTimer();

    _currentCall = null;

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();

    _durationSeconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;

      notifyListeners();
    });
  }

  String formattedDuration() {
    final minutes = _durationSeconds ~/ 60;

    final seconds = _durationSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOn = !_isCameraOn;

    notifyListeners();
  }

  void switchCamera() {
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;

    _durationSeconds = 0;

    _isMuted = false;

    _isCameraOn = true;
  }

  void clearCurrentCall() {
    _stopTimer();

    _currentCall = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _incomingSubscription?.cancel();

    _timer?.cancel();

    super.dispose();
  }
}
