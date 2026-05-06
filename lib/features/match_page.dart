import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import 'chat_page.dart';
// Timestamp is provided by cloud_firestore

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const bg = Color(0xFFF7F8FC);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF5B6CFF);
  static const teal = Color(0xFF3AAFA9);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const textDark = Color(0xFF1C1C1E);
  static const textMid = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);
  static const teachBg = Color(0xFFEFF6FF);
  static const teachText = Color(0xFF3B82F6);
  static const learnBg = Color(0xFFF0FDF4);
  static const learnText = Color(0xFF16A34A);
}

// ═══════════════════════════════════════════════════════════════════
//  MATCH PAGE
// ═══════════════════════════════════════════════════════════════════

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<_MatchSuggestion> _suggestions = [];
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;
  late String _currentUid;
  UserModel? _me;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser!.uid;
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _loading = true;
      _error = null;
      _currentIndex = 0;
    });

    try {
      final meDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .get();
      if (!meDoc.exists) throw Exception("User profile not found.");
      _me = UserModel.fromMap(meDoc.data()!);

      // Fetch matches where you are either User A or User B
      final sentMatches = await FirebaseFirestore.instance
          .collection('matches')
          .where('userAId', isEqualTo: _currentUid)
          .get();

      final receivedMatches = await FirebaseFirestore.instance
          .collection('matches')
          .where('userBId', isEqualTo: _currentUid)
          .get();

      // Combine all interacted UIDs into one set
      final alreadyActedOn = {
        ...sentMatches.docs.map((d) => d['userBId'] as String),
        ...receivedMatches.docs.map((d) => d['userAId'] as String),
      };

      // Fetch blocked UIDs in both directions
      final blockedByMe = await FirebaseFirestore.instance
          .collection('blocks')
          .where('blockerId', isEqualTo: _currentUid)
          .get();

      final blockedByOthers = await FirebaseFirestore.instance
          .collection('blocks')
          .where('blockedId', isEqualTo: _currentUid)
          .get();

      final blockedUids = {
        ...blockedByMe.docs.map((d) => d.data()['blockedId'] as String),
        ...blockedByOthers.docs.map((d) => d.data()['blockerId'] as String),
      };

      final allUsersSnap = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final suggestions = <_MatchSuggestion>[];

      for (final doc in allUsersSnap.docs) {
        final other = UserModel.fromMap(doc.data());

        // Filter out yourself and anyone you've already interacted with
        if (other.uid == _currentUid ||
            alreadyActedOn.contains(other.uid) ||
            blockedUids.contains(other.uid))
          continue;

        final theyTeachMe = other.teachSkills
            .toSet()
            .intersection(_me!.learnSkills.toSet())
            .toList();
        final iTeachThem = _me!.teachSkills
            .toSet()
            .intersection(other.learnSkills.toSet())
            .toList();

        if (theyTeachMe.isNotEmpty && iTeachThem.isNotEmpty) {
          suggestions.add(
            _MatchSuggestion(
              user: other,
              theyTeachMe: theyTeachMe,
              iTeachThem: iTeachThem,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _accept() async {
    if (_currentIndex >= _suggestions.length) return;
    final suggestion = _suggestions[_currentIndex];

    try {
      // Check if the other person already sent a request to you
      final existingSnap = await FirebaseFirestore.instance
          .collection('matches')
          .where('userAId', isEqualTo: suggestion.user.uid)
          .where('userBId', isEqualTo: _currentUid)
          .get();

      if (existingSnap.docs.isNotEmpty) {
        // Complete the mutual match
        await existingSnap.docs.first.reference.update({'status': 'matched'});
        String chatId = await _createChat(suggestion.user.uid);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chatId,
              matchId: existingSnap.docs.first.id,
              otherUid: suggestion.user.uid,
              name: suggestion.user.name,
              profilePicUrl: suggestion.user.profilePicUrl,
            ),
          ),
        );
      } else {
        // Start a new pending match
        final match = MatchModel(
          matchId: '',
          userAId: _currentUid,
          userBId: suggestion.user.uid,
          status: 'pending',
          createdAt: Timestamp.now(),
        );
        await FirebaseFirestore.instance
            .collection('matches')
            .add(match.toMap());
        _next();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Helper for UI feedback
  void _handleError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<String> _createChat(String otherUid) async {
    try {
      // Generate a deterministic ID (e.g., "user123_user456")
      // This ensures both users always point to the same chat document
      List<String> ids = [_currentUid, otherUid]..sort();
      String chatId = ids.join('_');

      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId);
      final doc = await chatRef.get();

      if (!doc.exists) {
        // Create the chat document if it's new[cite: 2]
        await chatRef.set({
          'userAId': ids[0],
          'userBId': ids[1],
          'uids': ids, // Array for easier 'array-contains' queries
          'lastMessage': 'Match created! Say hello.',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return chatId;
    } on FirebaseException catch (e) {
      throw Exception("Failed to initialize chat: ${e.message}");
    } catch (e) {
      throw Exception("Chat creation failed: $e");
    }
  }

  void _decline() => _next();

  void _next() {
    setState(() => _currentIndex++);
  }

  void _showMatchDialog(UserModel other) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "It's a Match! 🎉",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You and ${other.name.split(' ').first} have matched!\nHead to Chat to get started.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _C.textMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _C.primary))
            : _error != null
            ? _ErrorView(error: _error!, onRetry: _loadSuggestions)
            : _suggestions.isEmpty
            ? _EmptyView(onRefresh: _loadSuggestions)
            : _currentIndex >= _suggestions.length
            ? _DoneView(onRefresh: _loadSuggestions)
            : _buildMatchView(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _C.card,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF3953E8), Color(0xFF3AAFA9)],
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: _C.textDark),
          onPressed: _loadSuggestions,
          tooltip: 'Refresh suggestions',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildMatchView() {
    final suggestion = _suggestions[_currentIndex];
    final remaining = _suggestions.length - _currentIndex;

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Text(
                '$remaining suggestion${remaining != 1 ? 's' : ''} for you',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.textMid,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1} / ${_suggestions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.textLight,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Match card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _MatchCard(suggestion: suggestion),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decline
              _ActionBtn(
                onTap: _decline,
                icon: Icons.close_rounded,
                colors: const [Color(0xFFFF6B6B), Color(0xFFEF4444)],
                shadowColor: const Color(0xFFEF4444),
                size: 60,
              ),

              // Skip / Next
              _ActionBtn(
                onTap: _next,
                icon: Icons.arrow_forward_rounded,
                colors: const [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
                shadowColor: const Color(0xFF5B6CFF),
                size: 52,
              ),

              // Accept
              _ActionBtn(
                onTap: _accept,
                icon: Icons.check_rounded,
                colors: const [Color(0xFF4ADE80), Color(0xFF22C55E)],
                shadowColor: const Color(0xFF22C55E),
                size: 60,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MATCH CARD
// ═══════════════════════════════════════════════════════════════════

class _MatchCard extends StatelessWidget {
  final _MatchSuggestion suggestion;
  const _MatchCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final user = suggestion.user;
    final hasPhoto = user.profilePicUrl.isNotEmpty;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6CFF).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Name ──
            Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: hasPhoto
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B6CFF).withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: hasPhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            user.profilePicUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _InitialAvatar(initial: initial),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Match strength badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${suggestion.theyTeachMe.length + suggestion.iTeachThem.length} skill overlap',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Bio ──
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(color: _C.divider, height: 1),
              const SizedBox(height: 16),
              Text(
                user.bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: _C.textMid,
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 20),
            const Divider(color: _C.divider, height: 1),
            const SizedBox(height: 16),

            // ── They teach me ──
            _SkillGroup(
              label: 'They can teach you',
              icon: Icons.school_outlined,
              color: _C.teachText,
              bgColor: _C.teachBg,
              skills: suggestion.theyTeachMe,
            ),

            const SizedBox(height: 14),

            // ── I teach them ──
            _SkillGroup(
              label: 'You can teach them',
              icon: Icons.emoji_objects_outlined,
              color: _C.learnText,
              bgColor: _C.learnBg,
              skills: suggestion.iTeachThem,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SKILL GROUP
// ═══════════════════════════════════════════════════════════════════

class _SkillGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bgColor;
  final List<String> skills;

  const _SkillGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: skills
              .map(
                (s) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════

class _ActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final List<Color> colors;
  final Color shadowColor;
  final double size;

  const _ActionBtn({
    required this.onTap,
    required this.icon,
    required this.colors,
    required this.shadowColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.44),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY / DONE / ERROR STATES
// ═══════════════════════════════════════════════════════════════════

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No matches found yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _C.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add more skills to your profile to find people with overlapping interests.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _C.textMid, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _DoneView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.done_all_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You're all caught up!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _C.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You've gone through all your suggestions. Check back later or refresh.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _C.textMid, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: _C.danger),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _C.textMid),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF3AAFA9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DATA CLASS
// ═══════════════════════════════════════════════════════════════════

class _MatchSuggestion {
  final UserModel user;
  final List<String> theyTeachMe;
  final List<String> iTeachThem;

  const _MatchSuggestion({
    required this.user,
    required this.theyTeachMe,
    required this.iTeachThem,
  });
}
