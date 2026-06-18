import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../welcome_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const bg = Color(0xFFF8F9FF);
  static const primary = Color(0xFF005DA7);
  static const surface = Colors.white;
  static const textDark = Color(0xFF191C21);
  static const textMid = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFF2F3FB);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
}

// ═══════════════════════════════════════════════════════════════════
//  ADMIN PAGE
// ═══════════════════════════════════════════════════════════════════

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _reportFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Report actions ────────────────────────────────────────────────

  Future<void> _updateStatus(String reportId, String status) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update(
      {'status': status},
    );
  }

  Future<void> _deleteReview(String reportId, String reviewId) async {
    final confirm = await _showConfirmDialog(
      'Delete Review',
      'This will permanently delete the review. This cannot be undone.',
    );
    if (!confirm) return;

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .delete();
    await _updateStatus(reportId, 'resolved');

    if (!mounted) return;
    _showSnack('Review deleted and report resolved.', _C.success);
  }

  Future<void> _banUserFromReport(String reportId, String userId) async {
    final confirm = await _showConfirmDialog(
      'Ban User',
      'This will permanently ban the user from SkillBridge.',
    );
    if (!confirm) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'banned': true,
    });
    await _updateStatus(reportId, 'resolved');

    if (!mounted) return;
    _showSnack('User banned and report resolved.', _C.success);
  }

  // ── User actions ──────────────────────────────────────────────────

  Future<void> _toggleBan(String userId, bool currentlyBanned) async {
    final action = currentlyBanned ? 'Unban' : 'Ban';
    final body = currentlyBanned
        ? 'This will restore the user\'s access to SkillBridge.'
        : 'This will permanently ban the user from SkillBridge.';

    final confirm = await _showConfirmDialog(action, body);
    if (!confirm) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'banned': !currentlyBanned,
    });

    if (!mounted) return;
    _showSnack(
      currentlyBanned ? 'User unbanned.' : 'User banned.',
      currentlyBanned ? _C.success : _C.danger,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Future<bool> _showConfirmDialog(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _C.textDark,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(fontSize: 13, color: _C.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: _C.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 1,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _C.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: _C.danger),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _C.primary,
          unselectedLabelColor: _C.textMid,
          indicatorColor: _C.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Reports'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReportsTab(
            filter: _reportFilter,
            onFilterChanged: (f) => setState(() => _reportFilter = f),
            onUpdateStatus: _updateStatus,
            onDeleteReview: _deleteReview,
            onBanUser: _banUserFromReport,
          ),
          _UsersTab(onToggleBan: _toggleBan),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REPORTS TAB
// ═══════════════════════════════════════════════════════════════════

class _ReportsTab extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final Future<void> Function(String, String) onUpdateStatus;
  final Future<void> Function(String, String) onDeleteReview;
  final Future<void> Function(String, String) onBanUser;

  const _ReportsTab({
    required this.filter,
    required this.onFilterChanged,
    required this.onUpdateStatus,
    required this.onDeleteReview,
    required this.onBanUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Status filter chips ──────────────────────────────────
        Container(
          color: _C.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['pending', 'resolved', 'dismissed'].map((f) {
              final selected = filter == f;
              return GestureDetector(
                onTap: () => onFilterChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _C.primary : _C.divider,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f[0].toUpperCase() + f.substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _C.textMid,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Reports list ─────────────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .where('status', isEqualTo: filter)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: _C.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No $filter reports',
                        style: const TextStyle(
                          fontSize: 15,
                          color: _C.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final report = ReportModel.fromMap(
                    docs[index].data() as Map<String, dynamic>,
                    docs[index].id,
                  );
                  return _ReportCard(
                    report: report,
                    onResolve: () =>
                        onUpdateStatus(report.reportId, 'resolved'),
                    onDismiss: () =>
                        onUpdateStatus(report.reportId, 'dismissed'),
                    onDeleteReview: () =>
                        onDeleteReview(report.reportId, report.targetId),
                    onBanUser: () =>
                        onBanUser(report.reportId, report.reportedId),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  USERS TAB
// ═══════════════════════════════════════════════════════════════════

class _UsersTab extends StatelessWidget {
  final Future<void> Function(String userId, bool currentlyBanned) onToggleBan;

  const _UsersTab({required this.onToggleBan});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _C.primary),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(fontSize: 15, color: _C.textLight),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final user = UserModel.fromMap(data);
            final banned = data['banned'] as bool? ?? false;

            return _UserCard(
              user: user,
              banned: banned,
              onToggleBan: () => onToggleBan(user.uid, banned),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  USER CARD
// ═══════════════════════════════════════════════════════════════════

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool banned;
  final VoidCallback onToggleBan;

  const _UserCard({
    required this.user,
    required this.banned,
    required this.onToggleBan,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.profilePicUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: banned ? _C.danger.withOpacity(0.3) : _C.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFD4E3FF),
            child: hasPhoto
                ? ClipOval(
                    child: Image.network(
                      user.profilePicUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // ── Info ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textDark,
                      ),
                    ),
                    if (banned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _C.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Banned',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: _C.textMid),
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.bio,
                    style: const TextStyle(fontSize: 12, color: _C.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── Ban / Unban button ─────────────────────────────────
          GestureDetector(
            onTap: onToggleBan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: banned
                    ? _C.success.withOpacity(0.08)
                    : _C.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: banned
                      ? _C.success.withOpacity(0.3)
                      : _C.danger.withOpacity(0.3),
                ),
              ),
              child: Text(
                banned ? 'Unban' : 'Ban',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: banned ? _C.success : _C.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REPORT CARD
// ═══════════════════════════════════════════════════════════════════

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  final VoidCallback onDeleteReview;
  final VoidCallback onBanUser;

  const _ReportCard({
    required this.report,
    required this.onResolve,
    required this.onDismiss,
    required this.onDeleteReview,
    required this.onBanUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: report.targetType == 'review'
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.targetType == 'review' ? '📝 Review' : '👤 User',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: report.targetType == 'review'
                          ? const Color(0xFFB45309)
                          : _C.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _C.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.reason,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _C.danger,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(report.createdAt.toDate()),
                  style: const TextStyle(fontSize: 11, color: _C.textLight),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: _C.divider),

          // ── Reported content ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: report.targetType == 'review'
                ? _ReviewContent(reviewId: report.targetId)
                : _UserContent(userId: report.reportedId),
          ),

          // ── Reporter's note ──────────────────────────────────────
          if (report.details != null && report.details!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _C.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reporter\'s note',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.textMid,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.details!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _C.textDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Actions ──────────────────────────────────────────────
          if (report.status == 'pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  if (report.targetType == 'review')
                    _ActionButton(
                      label: 'Delete Review',
                      icon: Icons.delete_outline_rounded,
                      color: _C.danger,
                      onTap: onDeleteReview,
                    ),
                  if (report.targetType == 'user')
                    _ActionButton(
                      label: 'Ban User',
                      icon: Icons.block_rounded,
                      color: _C.danger,
                      onTap: onBanUser,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Resolve',
                          icon: Icons.check_circle_outline_rounded,
                          color: _C.success,
                          onTap: onResolve,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Dismiss',
                          icon: Icons.cancel_outlined,
                          color: _C.textMid,
                          onTap: onDismiss,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEW CONTENT
// ═══════════════════════════════════════════════════════════════════

class _ReviewContent extends StatelessWidget {
  final String reviewId;
  const _ReviewContent({required this.reviewId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _C.primary,
              ),
            ),
          );
        }
        if (!snapshot.data!.exists) {
          return const Text(
            'Review no longer exists.',
            style: TextStyle(fontSize: 13, color: _C.textLight),
          );
        }

        final review = ReviewModel.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
          snapshot.data!.id,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: i < review.rating ? _C.warning : _C.divider,
                  size: 16,
                );
              }),
            ),
            if (review.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                review.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: _C.textDark,
                  height: 1.5,
                ),
              ),
            ],
            if (review.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: review.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _C.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.textMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  USER CONTENT
// ═══════════════════════════════════════════════════════════════════

class _UserContent extends StatelessWidget {
  final String userId;
  const _UserContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _C.primary,
              ),
            ),
          );
        }
        if (!snapshot.data!.exists) {
          return const Text(
            'User no longer exists.',
            style: TextStyle(fontSize: 13, color: _C.textLight),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? 'Unknown';
        final bio = data['bio'] as String? ?? '';
        final pic = data['profilePicUrl'] as String? ?? '';
        final banned = data['banned'] as bool? ?? false;

        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFD4E3FF),
              child: pic.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        pic,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                        ),
                      ),
                      if (banned) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _C.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Banned',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _C.danger,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (bio.isNotEmpty)
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.textMid,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
