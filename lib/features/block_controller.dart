import 'package:flutter/foundation.dart';

/// Manages blocked users globally.
/// Access via BlockController.instance
class BlockController extends ChangeNotifier {
  static final BlockController instance = BlockController._();
  BlockController._();

  final Map<String, BlockedUser> _blocked = {};

  List<BlockedUser> get all =>
      _blocked.values.toList()
        ..sort((a, b) => b.blockedAt.compareTo(a.blockedAt));

  int get count => _blocked.length;

  bool isBlocked(String userId) => _blocked.containsKey(userId);

  void block({
    required String userId,
    required String name,
    String? imageUrl,
    String? avatarText,
  }) {
    _blocked[userId] = BlockedUser(
      userId: userId,
      name: name,
      imageUrl: imageUrl,
      avatarText: avatarText,
      blockedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void unblock(String userId) {
    _blocked.remove(userId);
    notifyListeners();
  }
}

class BlockedUser {
  final String userId;
  final String name;
  final String? imageUrl;
  final String? avatarText;
  final DateTime blockedAt;

  BlockedUser({
    required this.userId,
    required this.name,
    this.imageUrl,
    this.avatarText,
    required this.blockedAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(blockedAt);
    if (diff.inDays > 7) {
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[blockedAt.month]} ${blockedAt.day}, ${blockedAt.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
