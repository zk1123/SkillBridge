import 'package:flutter/foundation.dart';

/// Manages live session invites (mentor → student).
class LiveInviteController extends ChangeNotifier {
  static final LiveInviteController instance = LiveInviteController._();
  LiveInviteController._();

  final List<LiveInvite> _invites = [];

  List<LiveInvite> get pending =>
      _invites.where((i) => i.status == InviteStatus.pending).toList();

  int get pendingCount => pending.length;

  LiveInvite send({
    required String mentorName,
    required String mentorImage,
    required String studentId,
    required String studentName,
    required String studentImage,
    required String topic,
    int durationMinutes = 60,
  }) {
    final invite = LiveInvite(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}_$studentId',
      mentorName: mentorName,
      mentorImage: mentorImage,
      studentId: studentId,
      studentName: studentName,
      studentImage: studentImage,
      topic: topic,
      durationMinutes: durationMinutes,
      sentAt: DateTime.now(),
      status: InviteStatus.pending,
    );
    _invites.add(invite);
    notifyListeners();
    return invite;
  }

  void accept(String inviteId) {
    final i = _invites.indexWhere((inv) => inv.id == inviteId);
    if (i != -1) {
      _invites[i] = _invites[i].copyWith(status: InviteStatus.accepted);
      notifyListeners();
    }
  }

  void decline(String inviteId) {
    final i = _invites.indexWhere((inv) => inv.id == inviteId);
    if (i != -1) {
      _invites[i] = _invites[i].copyWith(status: InviteStatus.declined);
      notifyListeners();
    }
  }
}

enum InviteStatus { pending, accepted, declined }

class LiveInvite {
  final String id;
  final String mentorName;
  final String mentorImage;
  final String studentId;
  final String studentName;
  final String studentImage;
  final String topic;
  final int durationMinutes;
  final DateTime sentAt;
  final InviteStatus status;

  LiveInvite({
    required this.id,
    required this.mentorName,
    required this.mentorImage,
    required this.studentId,
    required this.studentName,
    required this.studentImage,
    required this.topic,
    required this.durationMinutes,
    required this.sentAt,
    required this.status,
  });

  LiveInvite copyWith({InviteStatus? status}) => LiveInvite(
        id: id,
        mentorName: mentorName,
        mentorImage: mentorImage,
        studentId: studentId,
        studentName: studentName,
        studentImage: studentImage,
        topic: topic,
        durationMinutes: durationMinutes,
        sentAt: sentAt,
        status: status ?? this.status,
      );
}