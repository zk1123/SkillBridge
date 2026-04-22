import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String userAId;
  final String userBId;
  final String status;
  final Timestamp createdAt;

  MatchModel({
    required this.matchId,
    required this.userAId,
    required this.userBId,
    required this.status,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      matchId: id,
      userAId: map['userAId'],
      userBId: map['userBId'],
      status: map['status'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userAId': userAId,
      'userBId': userBId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
