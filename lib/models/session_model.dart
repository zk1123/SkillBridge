import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String matchId;
  final String proposerId;
  final String topic;
  final Timestamp scheduledAt;
  final String status;
  final Timestamp createdAt;

  SessionModel({
    required this.sessionId,
    required this.matchId,
    required this.proposerId,
    required this.topic,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      sessionId: id,
      matchId: map['matchId'],
      proposerId: map['proposerId'],
      topic: map['topic'],
      scheduledAt: map['scheduledAt'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'proposerId': proposerId,
      'topic': topic,
      'scheduledAt': scheduledAt,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
