import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String matchId;
  final String proposerId;
  final String responderId; // NEW
  final String teacherId; // NEW
  final String learnerId; // NEW
  final String topic;
  final int durationMinutes; // NEW
  final Timestamp scheduledAt;
  final String status; // pending_response | confirmed | cancelled | completed
  final String callStatus; // NEW: idle | ringing | in_call | ended
  final Timestamp createdAt;
  final Timestamp? respondedAt; // NEW — nullable

  SessionModel({
    required this.sessionId,
    required this.matchId,
    required this.proposerId,
    required this.responderId,
    required this.teacherId,
    required this.learnerId,
    required this.topic,
    required this.durationMinutes,
    required this.scheduledAt,
    required this.status,
    required this.callStatus,
    required this.createdAt,
    this.respondedAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      sessionId: id,
      matchId: map['matchId'],
      proposerId: map['proposerId'],
      responderId: map['responderId'],
      teacherId: map['teacherId'],
      learnerId: map['learnerId'],
      topic: map['topic'],
      durationMinutes: map['durationMinutes'] ?? 60,
      scheduledAt: map['scheduledAt'],
      status: map['status'] ?? 'pending_response',
      callStatus: map['callStatus'] ?? 'idle',
      createdAt: map['createdAt'],
      respondedAt: map['respondedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'proposerId': proposerId,
      'responderId': responderId,
      'teacherId': teacherId,
      'learnerId': learnerId,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'scheduledAt': scheduledAt,
      'status': status,
      'callStatus': callStatus,
      'createdAt': createdAt,
      if (respondedAt != null) 'respondedAt': respondedAt,
    };
  }
}
