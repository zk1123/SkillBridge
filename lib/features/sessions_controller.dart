import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottomnavbar.dart';
import 'notifications_controller.dart';
import 'wallet_controller.dart';
import 'subscriptions_controller.dart';
import 'live_invite_controller.dart';
import 'live_invite_sheet.dart';
import 'create_live_session_sheet.dart';
import 'chat_page.dart';

enum SessionStatus { confirmed, pending, completed, cancelled, rejected }

enum SessionType { learning, teaching }

enum PaymentSource { wallet, package, free }

class Session {
  final String id;
  final String name;
  final String avatarUrl;
  String date;
  final List<String> tags;
  final SessionType type;
  final String subject;
  SessionStatus status;

  final double amount;
  final PaymentSource source;
  final String? packageId;
  bool refunded;

  Session({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    required this.date,
    required this.tags,
    required this.type,
    required this.subject,
    this.status = SessionStatus.pending,
    this.amount = 0,
    this.source = PaymentSource.free,
    this.packageId,
    this.refunded = false,
  });
}

class SessionsController extends ChangeNotifier {
  static final SessionsController instance = SessionsController._();
  SessionsController._();

  final List<Session> _sessions = [
    // 🆕 Test sessions for Mohamed & Marwan (confirmed, so you can message + call them)
    Session(
      id: 's_mohamed',
      name: 'Mohamed Nukbassy',
      avatarUrl: 'https://i.postimg.cc/QtQ8gFb3/Mohamed.webp',
      date: 'Today | 7:00 PM – 8:00 PM',
      tags: ['Flutter', 'Architecture'],
      type: SessionType.learning,
      subject: 'Flutter Clean Architecture',
      status: SessionStatus.confirmed,
      amount: 350,
      source: PaymentSource.wallet,
    ),
    Session(
      id: 's_marwan',
      name: 'Marwan Hussien',
      avatarUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
      date: 'Tomorrow | 5:00 PM – 6:30 PM',
      tags: ['Flutter', 'Video Editing'],
      type: SessionType.learning,
      subject: 'Flutter UI & Animations',
      status: SessionStatus.confirmed,
      amount: 280,
      source: PaymentSource.wallet,
    ),
    Session(
      id: 's1',
      name: 'Elena Rodriguez',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      date: 'Oct 24, 2023 | 10:00 AM – 11:30 AM',
      tags: ['UI', 'Motion', 'Design'],
      type: SessionType.learning,
      subject: 'UI/UX Design',
      status: SessionStatus.confirmed,
      amount: 240,
      source: PaymentSource.wallet,
    ),
    Session(
      id: 's2',
      name: 'Marcus Chen',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      date: 'Oct 26, 2023 | 4:00 PM – 5:00 PM',
      tags: ['Advanced', 'React'],
      type: SessionType.teaching,
      subject: 'React Patterns',
      status: SessionStatus.pending,
      amount: 0,
      source: PaymentSource.free,
    ),
    Session(
      id: 's3',
      name: 'Aisha Kamara',
      avatarUrl: 'https://randomuser.me/api/portraits/women/17.jpg',
      date: 'Oct 10, 2023 | 2:00 PM – 3:00 PM',
      tags: ['Python', 'Data', 'ML'],
      type: SessionType.learning,
      subject: 'Machine Learning',
      status: SessionStatus.completed,
      amount: 300,
      source: PaymentSource.wallet,
    ),
  ];

  List<Session> get all => List.unmodifiable(_sessions);

  List<Session> get upcoming => _sessions
      .where(
        (s) =>
            s.status == SessionStatus.confirmed ||
            s.status == SessionStatus.pending,
      )
      .toList();

  List<Session> get past => _sessions
      .where(
        (s) =>
            s.status == SessionStatus.completed ||
            s.status == SessionStatus.cancelled ||
            s.status == SessionStatus.rejected,
      )
      .toList();

  /// 🆕 Confirmed sessions — for the Create Live Session picker
  List<Session> get accepted =>
      _sessions.where((s) => s.status == SessionStatus.confirmed).toList();

  void addBookedSession({
    required String mentorName,
    required String mentorImage,
    required String subject,
    required String date,
    required List<String> tags,
    required double amount,
    required PaymentSource source,
    String? packageId,
  }) {
    _sessions.insert(
      0,
      Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: mentorName,
        avatarUrl: mentorImage,
        date: date,
        tags: tags,
        type: SessionType.learning,
        subject: subject,
        status: SessionStatus.pending,
        amount: amount,
        source: source,
        packageId: packageId,
      ),
    );
    notifyListeners();
  }

  void accept(Session session) {
    session.status = SessionStatus.confirmed;
    NotificationsController.instance.addSessionAccepted(
      personName: session.name,
      avatarUrl: session.avatarUrl,
      subject: session.subject,
      dateStr: session.date,
    );
    notifyListeners();
  }

  void reject(Session session, {String? reason}) {
    session.status = SessionStatus.rejected;
    _refundSession(session);
    NotificationsController.instance.addSessionCancelled(
      personName: session.name,
      avatarUrl: session.avatarUrl,
      subject: session.subject,
    );
    notifyListeners();
  }

  void cancel(Session session) {
    session.status = SessionStatus.cancelled;
    _refundSession(session);
    NotificationsController.instance.addSessionCancelled(
      personName: session.name,
      avatarUrl: session.avatarUrl,
      subject: session.subject,
    );
    notifyListeners();
  }

  void _refundSession(Session session) {
    if (session.refunded) return;
    if (session.source == PaymentSource.wallet && session.amount > 0) {
      WalletController.instance.refund(
        session.amount,
        'Refund: Session with ${session.name}',
        recipient: session.name,
      );
      session.refunded = true;
    } else if (session.source == PaymentSource.package &&
        session.packageId != null) {
      SubscriptionsController.instance.returnSessionToPackage(
        session.packageId!,
      );
      session.refunded = true;
    }
  }

  void reschedule(Session session, String newDate) {
    session.date = newDate;
    if (session.status == SessionStatus.cancelled ||
        session.status == SessionStatus.rejected) {
      session.status = SessionStatus.pending;
    }
    notifyListeners();
  }
}
