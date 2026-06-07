import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';

class ReportService {
  static Future<void> submitReport({
    required String reportedId,
    required String targetType, // 'user' | 'review'
    required String
    targetId, // uid for user reports, reviewId for review reports
    required String reason,
    String? details,
  }) async {
    final reporterId = FirebaseAuth.instance.currentUser!.uid;

    final report = ReportModel(
      reportId: '',
      reporterId: reporterId,
      reportedId: reportedId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details?.trim().isEmpty ?? true ? null : details?.trim(),
      status: 'pending',
      createdAt: Timestamp.now(),
    );
    print('DEBUG report map: ${report.toMap()}');
    await FirebaseFirestore.instance.collection('reports').add(report.toMap());
  }
}
