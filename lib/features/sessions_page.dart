import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../models/review_model.dart';
import 'chat_page.dart';
import 'profile_view_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const bgMain = Color(0xFFF7F8FC);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgInput = Color(0xFFF1F2F6);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFD97706);
  static const primary = Color(0xFF5B6CFF);
  static const border = Color(0xFFE5E7EB);
  static const tagBlue = Color(0xFFE0F2FE);
  static const tagGreen = Color(0xFFDCFCE7);
  static const tagPurple = Color(0xFFEDE9FE);
  static const tagYellow = Color(0xFFFEF3C7);
  static const logoBlue = Color(0xFF3953E8);
  static const logoTeal = Color(0xFF3AAFA9);
  static const star = Color(0xFFF59E0B);
}

// ═══════════════════════════════════════════════════════════════════
//  SESSIONS PAGE
// ═══════════════════════════════════════════════════════════════════

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool _showUpcoming = true;
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;

  // ── Resolve other user's profile from a session ─────────────────

  Future<Map<String, dynamic>?> _resolveOtherUser(SessionModel session) async {
    final otherUid = session.teacherId == _currentUid
        ? session.learnerId
        : session.teacherId;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get();
    if (!doc.exists) return null;
    return {
      'uid': otherUid,
      'name': doc.data()?['name'] ?? 'Unknown',
      'profilePicUrl': doc.data()?['profilePicUrl'] ?? '',
    };
  }

  // ── Derive chatId deterministically ─────────────────────────────

  String _chatId(String otherUid) {
    final ids = [_currentUid, otherUid]..sort();
    return ids.join('_');
  }

  // ── Session actions ──────────────────────────────────────────────

  Future<void> _acceptSession(String sessionId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({
          'status': 'confirmed',
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _cancelSession(String sessionId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({'status': 'cancelled'});
  }

  Future<void> _declineSession(String sessionId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({
          'status': 'cancelled',
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }

  void _goToChat(
    String otherUid,
    String name,
    String profilePicUrl,
    String matchId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatId: _chatId(otherUid),
          matchId: matchId,
          otherUid: otherUid,
          name: name,
          profilePicUrl: profilePicUrl,
        ),
      ),
    );
  }

  // ── Review action ────────────────────────────────────────────────

  void _openReviewSheet(
    SessionModel session,
    String otherUid,
    String otherName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        currentUid: _currentUid,
        reviewedUid: otherUid,
        reviewedName: otherName,
        matchId: session.matchId,
        sessionId: session.sessionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgMain,
      appBar: AppBar(
        backgroundColor: _C.bgCard,
        elevation: 0,
        leading: const Icon(Icons.menu, color: _C.textPrimary),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_C.logoBlue, _C.logoTeal],
          ).createShader(bounds),
          child: const Text(
            'SkillBridge',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.search, color: _C.textPrimary),
          SizedBox(width: 12),
          Icon(Icons.person_outline, color: _C.textPrimary),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            color: _C.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: const Text(
              'My Sessions',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _C.textPrimary,
              ),
            ),
          ),

          // ── Tabs ────────────────────────────────────────────────
          Container(
            color: _C.bgCard,
            child: Row(
              children: [
                _Tab(
                  label: 'Upcoming',
                  isActive: _showUpcoming,
                  onTap: () => setState(() => _showUpcoming = true),
                ),
                _Tab(
                  label: 'Past',
                  isActive: !_showUpcoming,
                  onTap: () => setState(() => _showUpcoming = false),
                ),
              ],
            ),
          ),

          // ── Subtitle ────────────────────────────────────────────
          Container(
            color: _C.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              _showUpcoming
                  ? 'Manage your upcoming peer-to-peer learning exchanges.'
                  : 'Your completed and cancelled sessions.',
              style: const TextStyle(color: _C.textSecondary, fontSize: 13),
            ),
          ),

          const SizedBox(height: 8),

          // ── Session list ─────────────────────────────────────────
          Expanded(
            child: _SessionList(
              currentUid: _currentUid,
              showUpcoming: _showUpcoming,
              resolveOtherUser: _resolveOtherUser,
              onAccept: _acceptSession,
              onCancel: _cancelSession,
              onDecline: _declineSession,
              onMessage: _goToChat,
              onReview: _openReviewSheet, // ← new
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SESSION LIST
// ═══════════════════════════════════════════════════════════════════

class _SessionList extends StatelessWidget {
  final String currentUid;
  final bool showUpcoming;
  final Future<Map<String, dynamic>?> Function(SessionModel) resolveOtherUser;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onCancel;
  final Future<void> Function(String) onDecline;
  final void Function(String, String, String, String) onMessage;
  final void Function(SessionModel, String, String) onReview; // ← new

  const _SessionList({
    required this.currentUid,
    required this.showUpcoming,
    required this.resolveOtherUser,
    required this.onAccept,
    required this.onCancel,
    required this.onDecline,
    required this.onMessage,
    required this.onReview, // ← new
  });

  List<String> get _statusFilter => showUpcoming
      ? ['pending_response', 'confirmed']
      : ['completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    final streamA = FirebaseFirestore.instance
        .collection('sessions')
        .where('proposerId', isEqualTo: currentUid)
        .where('status', whereIn: _statusFilter)
        .snapshots();

    final streamB = FirebaseFirestore.instance
        .collection('sessions')
        .where('responderId', isEqualTo: currentUid)
        .where('status', whereIn: _statusFilter)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: streamA,
      builder: (context, snapA) {
        return StreamBuilder<QuerySnapshot>(
          stream: streamB,
          builder: (context, snapB) {
            if (snapA.connectionState == ConnectionState.waiting ||
                snapB.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _C.primary),
              );
            }

            final allDocs = [...?snapA.data?.docs, ...?snapB.data?.docs];
            final seen = <String>{};
            final uniqueDocs = allDocs.where((d) => seen.add(d.id)).toList();

            uniqueDocs.sort((a, b) {
              final aTs = (a.data() as Map)['scheduledAt'] as Timestamp?;
              final bTs = (b.data() as Map)['scheduledAt'] as Timestamp?;
              if (aTs == null || bTs == null) return 0;
              return showUpcoming ? aTs.compareTo(bTs) : bTs.compareTo(aTs);
            });

            if (uniqueDocs.isEmpty) {
              return _EmptyState(showUpcoming: showUpcoming);
            }

            return FutureBuilder<List<_ResolvedSession>>(
              future: _resolveSessions(uniqueDocs),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primary),
                  );
                }

                final sessions = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: sessions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sessions.length) {
                      return _LookingForMoreBanner(context: context);
                    }
                    final s = sessions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SessionCard(
                        session: s.session,
                        otherName: s.otherName,
                        otherProfilePicUrl: s.otherProfilePicUrl,
                        otherUid: s.otherUid,
                        currentUid: currentUid,
                        onAccept: onAccept,
                        onCancel: onCancel,
                        onDecline: onDecline,
                        onMessage: onMessage,
                        onReview: onReview, // ← new
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<_ResolvedSession>> _resolveSessions(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final results = <_ResolvedSession>[];
    for (final doc in docs) {
      final session = SessionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      final otherUser = await resolveOtherUser(session);
      if (otherUser != null) {
        results.add(
          _ResolvedSession(
            session: session,
            otherUid: otherUser['uid'],
            otherName: otherUser['name'],
            otherProfilePicUrl: otherUser['profilePicUrl'],
          ),
        );
      }
    }
    return results;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SESSION CARD
// ═══════════════════════════════════════════════════════════════════

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final String otherName;
  final String otherProfilePicUrl;
  final String otherUid;
  final String currentUid;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onCancel;
  final Future<void> Function(String) onDecline;
  final void Function(String, String, String, String) onMessage;
  final void Function(SessionModel, String, String) onReview; // ← new

  const _SessionCard({
    required this.session,
    required this.otherName,
    required this.otherProfilePicUrl,
    required this.otherUid,
    required this.currentUid,
    required this.onAccept,
    required this.onCancel,
    required this.onDecline,
    required this.onMessage,
    required this.onReview, // ← new
  });

  bool get _isTeaching => session.teacherId == currentUid;
  bool get _isMyTurn => session.responderId == currentUid;
  bool get _isPending => session.status == 'pending_response';
  bool get _isConfirmed => session.status == 'confirmed';
  bool get _isCompleted => session.status == 'completed';
  bool get _isCancelled => session.status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    final scheduledDate = session.scheduledAt.toDate();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name & status ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewProfilePage(uid: otherUid),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFD4E3FF),
                      child: otherProfilePicUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                otherProfilePicUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  otherName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF2976C7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              otherName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF2976C7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      otherName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _C.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: session.status),
            ],
          ),

          const SizedBox(height: 10),

          // ── Role + topic ──
          Row(
            children: [
              _RoleChip(isTeaching: _isTeaching),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.topic,
                  style: const TextStyle(color: _C.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Date & duration ──
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 13,
                color: _C.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(scheduledDate),
                style: const TextStyle(color: _C.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.timer_outlined,
                size: 13,
                color: _C.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${session.durationMinutes} min',
                style: const TextStyle(color: _C.textSecondary, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Actions ──
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    // ── ONLY CHANGE IN THIS METHOD: completed case ──
    if (_isCompleted) {
      return _CompletedActions(
        sessionId: session.sessionId,
        currentUid: currentUid,
        onReview: () => onReview(session, otherUid, otherName),
      );
    }

    if (_isCancelled) {
      return const Text(
        'Session cancelled',
        style: TextStyle(
          fontSize: 12,
          color: _C.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Confirmed session
    if (_isConfirmed) {
      return Row(
        children: [
          _ActionBtn(
            label: 'Message',
            bg: _C.primary,
            textColor: Colors.white,
            icon: Icons.message_outlined,
            onTap: () => onMessage(
              otherUid,
              otherName,
              otherProfilePicUrl,
              session.matchId,
            ),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: 'Cancel',
            bg: _C.bgInput,
            textColor: _C.danger,
            icon: Icons.close_rounded,
            onTap: () => _confirmCancel(context),
          ),
        ],
      );
    }

    // Pending — my turn to respond
    if (_isPending && _isMyTurn) {
      return Row(
        children: [
          _ActionBtn(
            label: 'Accept',
            bg: _C.success,
            textColor: Colors.white,
            icon: Icons.check_rounded,
            onTap: () => onAccept(session.sessionId),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: 'Message',
            bg: _C.bgInput,
            textColor: _C.textPrimary,
            icon: Icons.message_outlined,
            onTap: () => onMessage(
              otherUid,
              otherName,
              otherProfilePicUrl,
              session.matchId,
            ),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: 'Decline',
            bg: _C.bgInput,
            textColor: _C.danger,
            icon: Icons.close_rounded,
            onTap: () => onDecline(session.sessionId),
          ),
        ],
      );
    }

    // Pending — waiting for other person
    if (_isPending && !_isMyTurn) {
      return Row(
        children: [
          _ActionBtn(
            label: 'Message',
            bg: _C.bgInput,
            textColor: _C.textPrimary,
            icon: Icons.message_outlined,
            onTap: () => onMessage(
              otherUid,
              otherName,
              otherProfilePicUrl,
              session.matchId,
            ),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: 'Cancel',
            bg: _C.bgInput,
            textColor: _C.danger,
            icon: Icons.close_rounded,
            onTap: () => _confirmCancel(context),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel session?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will cancel the session. This action cannot be undone.',
          style: TextStyle(color: _C.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel(session.sessionId);
            },
            child: const Text(
              'Cancel session',
              style: TextStyle(color: _C.danger),
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
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $h:$m $period';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COMPLETED ACTIONS
//  Checks Firestore to see if current user already left a review
//  for this session — shows "Leave a Review" or "Reviewed ✓"
// ═══════════════════════════════════════════════════════════════════

class _CompletedActions extends StatelessWidget {
  final String sessionId;
  final String currentUid;
  final VoidCallback onReview;

  const _CompletedActions({
    required this.sessionId,
    required this.currentUid,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('sessionId', isEqualTo: sessionId)
          .where('reviewerId', isEqualTo: currentUid)
          .limit(1)
          .snapshots(), // ← snapshots() instead of get()
      builder: (context, snapshot) {
        final alreadyReviewed =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        if (alreadyReviewed) {
          return const Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: _C.star),
              SizedBox(width: 4),
              Text(
                'Review submitted ✓',
                style: TextStyle(
                  fontSize: 12,
                  color: _C.star,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            const Text(
              'Session completed ✓',
              style: TextStyle(
                fontSize: 12,
                color: _C.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            _ActionBtn(
              label: 'Leave a Review',
              bg: _C.star.withOpacity(0.12),
              textColor: _C.star,
              icon: Icons.star_outline_rounded,
              onTap: onReview,
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEW BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _ReviewSheet extends StatefulWidget {
  final String currentUid;
  final String reviewedUid;
  final String reviewedName;
  final String matchId;
  final String sessionId;

  const _ReviewSheet({
    required this.currentUid,
    required this.reviewedUid,
    required this.reviewedName,
    required this.matchId,
    required this.sessionId,
  });

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 0;
  final _textController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = FirebaseFirestore.instance;

      // 1. Write the review doc
      final review = ReviewModel(
        reviewId: '',
        reviewerId: widget.currentUid,
        reviewedId: widget.reviewedUid,
        matchId: widget.matchId,
        sessionId: widget.sessionId,
        rating: _rating,
        tags: [],
        text: _textController.text.trim(),
        createdAt: Timestamp.now(),
      );
      await db.collection('reviews').add(review.toMap());

      // 2. Update averageRating and reviewCount on the reviewed user's doc
      //    We read current values first, then recalculate
      final userDoc = await db
          .collection('users')
          .doc(widget.reviewedUid)
          .get();
      final currentCount = (userDoc.data()?['reviewCount'] ?? 0) as int;
      final currentAvg = (userDoc.data()?['averageRating'] ?? 0.0).toDouble();

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + _rating) / newCount;

      await db.collection('users').doc(widget.reviewedUid).update({
        'reviewCount': newCount,
        'averageRating': double.parse(newAvg.toStringAsFixed(1)),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _C.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Review ${widget.reviewedName.split(' ').first}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'How was your session?',
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
          ),

          const SizedBox(height: 24),

          // Star rating
          const Text(
            'Rating',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? _C.star : _C.border,
                    size: 36,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Text review
          const Text(
            'Your thoughts (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Share what you learned or how the session went...',
              hintStyle: const TextStyle(color: _C.textSecondary, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 28),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
//  CHIPS & SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, color;
    String label;

    switch (status) {
      case 'confirmed':
        bg = _C.tagGreen;
        color = _C.success;
        label = 'CONFIRMED';
        break;
      case 'pending_response':
        bg = _C.tagYellow;
        color = _C.warning;
        label = 'PENDING';
        break;
      case 'completed':
        bg = _C.tagBlue;
        color = _C.primary;
        label = 'COMPLETED';
        break;
      case 'cancelled':
      default:
        bg = const Color(0xFFFEE2E2);
        color = _C.danger;
        label = 'CANCELLED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final bool isTeaching;
  const _RoleChip({required this.isTeaching});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTeaching ? _C.tagPurple : _C.tagBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isTeaching ? 'TEACHING' : 'LEARNING',
        style: TextStyle(
          color: isTeaching ? _C.primary : const Color(0xFF0369A1),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _C.primary : _C.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 60,
              color: isActive ? _C.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool showUpcoming;
  const _EmptyState({required this.showUpcoming});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                showUpcoming
                    ? Icons.calendar_today_outlined
                    : Icons.history_rounded,
                size: 36,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              showUpcoming ? 'No upcoming sessions' : 'No past sessions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showUpcoming
                  ? 'Go to a chat and propose a session with your match.'
                  : 'Completed and cancelled sessions will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _C.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOOKING FOR MORE BANNER
// ═══════════════════════════════════════════════════════════════════

class _LookingForMoreBanner extends StatelessWidget {
  final BuildContext context;
  const _LookingForMoreBanner({required this.context});

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7A59), Color(0xFFFFB36B)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'Looking for more?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Match with a peer to schedule your next session.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Find New Match',
                style: TextStyle(
                  color: Color(0xFFFF7A59),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DATA CLASS
// ═══════════════════════════════════════════════════════════════════

class _ResolvedSession {
  final SessionModel session;
  final String otherUid;
  final String otherName;
  final String otherProfilePicUrl;

  const _ResolvedSession({
    required this.session,
    required this.otherUid,
    required this.otherName,
    required this.otherProfilePicUrl,
  });
}
