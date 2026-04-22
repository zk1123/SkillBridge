import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? details;
  final String status;
  final Timestamp createdAt;

  ReportModel({
    required this.reportId,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.details,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      reportId: id,
      reporterId: map['reporterId'],
      reportedId: map['reportedId'],
      reason: map['reason'],
      details: map['details'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
