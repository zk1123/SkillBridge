// ═══════════════════════════════════════════════════════════════════
//  notifications_controller.dart
//  Singleton — import this in feed_page, sessions_page, match_page
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

enum NotifType {
  sessionBooked,    // Someone booked a session with you
  sessionAccepted,  // Someone accepted your session
  sessionCancelled, // Someone cancelled your session
  sessionPending,   // Session is pending
  newMessage,       // New message received
}

class AppNotification {
  final String    id;
  final String    title;
  final String    body;
  final String    avatarUrl;
  final NotifType type;
  final DateTime  time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.avatarUrl,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsController extends ChangeNotifier {
  static final NotificationsController instance = NotificationsController._();
  NotificationsController._();

  final List<AppNotification> _notifications = [
    // Demo notifications
    AppNotification(
      id: '1',
      title: 'Marwan Hussien accepted your session ✅',
      body: 'Flutter Development session starts Oct 15 at 10:00 AM',
      avatarUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
      type: NotifType.sessionAccepted,
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Mohamed Nukbassy booked a session with you 📅',
      body: 'Data Analysis | Oct 20 at 4:00 PM — 2 hours',
      avatarUrl: 'https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg',
      type: NotifType.sessionBooked,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Sara Khalil cancelled the session ❌',
      body: 'UI/UX Design session was cancelled. You can book another time.',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      type: NotifType.sessionCancelled,
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
  ];

  List<AppNotification> get all      => List.unmodifiable(_notifications);
  int  get unreadCount               => _notifications.where((n) => !n.isRead).length;

  // ── Called from Match page when a session is booked ──
  void addSessionBooked({
    required String personName,
    required String avatarUrl,
    required String subject,
    required String dateStr,
  }) {
    _notifications.insert(0, AppNotification(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      title:     'Session booked with $personName 📅',
      body:      '$subject | $dateStr',
      avatarUrl: avatarUrl,
      type:      NotifType.sessionBooked,
      time:      DateTime.now(),
    ));
    notifyListeners();
  }

  // ── Called from Sessions page when someone accepts ──
  void addSessionAccepted({
    required String personName,
    required String avatarUrl,
    required String subject,
    required String dateStr,
  }) {
    _notifications.insert(0, AppNotification(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      title:     '$personName accepted your session ✅',
      body:      '$subject | $dateStr',
      avatarUrl: avatarUrl,
      type:      NotifType.sessionAccepted,
      time:      DateTime.now(),
    ));
    notifyListeners();
  }

  // ── Called from Sessions page when someone cancels ──
  void addSessionCancelled({
    required String personName,
    required String avatarUrl,
    required String subject,
  }) {
    _notifications.insert(0, AppNotification(
      id:        DateTime.now().millisecondsSinceEpoch.toString(),
      title:     '$personName cancelled the session ❌',
      body:      '$subject was cancelled — you can rebook anytime',
      avatarUrl: avatarUrl,
      type:      NotifType.sessionCancelled,
      time:      DateTime.now(),
    ));
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) { n.isRead = true; }
    notifyListeners();
  }

  void markRead(String id) {
    final n = _notifications.firstWhere((x) => x.id == id, orElse: () => _notifications.first);
    n.isRead = true;
    notifyListeners();
  }

  void remove(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}