import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallStatus { calling, accepted, connected, rejected, missed, ended }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;

  final CallType type;
  final CallStatus status;

  final DateTime createdAt;
  final int duration;

  const CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.status,
    required this.createdAt,
    this.duration = 0,
  });

  factory CallModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return CallModel(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      type: data['type'] == 'video' ? CallType.video : CallType.audio,
      status: _statusFromString(data['status'] ?? 'calling'),
      createdAt: _dateFromFirestore(data['createdAt']),
      duration: (data['duration'] ?? 0) as int,
    );
  }

  static CallStatus _statusFromString(String value) {
    switch (value) {
      case 'accepted':
        return CallStatus.accepted;
      case 'connected':
        return CallStatus.connected;
      case 'rejected':
        return CallStatus.rejected;
      case 'missed':
        return CallStatus.missed;
      case 'ended':
        return CallStatus.ended;
      default:
        return CallStatus.calling;
    }
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'duration': duration,
    };
  }

  CallModel copyWith({CallStatus? status, int? duration}) {
    return CallModel(
      id: id,
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      duration: duration ?? this.duration,
    );
  }
}
