import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillbridge/features/app_bar.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar — same as Sessions & Messages ───────────────
            const SkillBridgeAppBar(),

            // ── Gradient header — matches Sessions & Messages ───────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF2563EB),
                    Color(0xFF059669),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match with new people',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discover peers who match your skills.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body — all existing logic completely untouched ──────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    )
                  : _error != null
                  ? _ErrorView(error: _error!, onRetry: _loadSuggestions)
                  : _suggestions.isEmpty
                  ? _EmptyView(onRefresh: _loadSuggestions)
                  : _currentIndex >= _suggestions.length
                  ? _DoneView(onRefresh: _loadSuggestions)
                  : _buildMatchView(),
            ),
          ],
        ),
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
  @override
  Widget build(BuildContext context) {
    final user = suggestion.user;
    final hasPhoto = user.profilePicUrl.isNotEmpty;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    // Deterministic gradient per user initial — same pattern as conversation items
    const List<List<Color>> _avatarGradients = [
      [Color(0xFF1E40AF), Color(0xFF2563EB)],
      [Color(0xFF059669), Color(0xFF34D399)],
      [Color(0xFF7C3AED), Color(0xFFA78BFA)],
      [Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF2563EB), Color(0xFF059669)],
    ];
    final gradColors =
        _avatarGradients[user.name.isNotEmpty
            ? user.name.codeUnitAt(0) % _avatarGradients.length
            : 0];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            // ── Hero avatar block ───────────────────────────────────
            Center(
              child: Column(
                children: [
                  // Gradient ring around avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradColors[0].withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: hasPhoto
                            ? ClipOval(
                                child: Image.network(
                                  user.profilePicUrl,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _InitialAvatar(initial: initial),
                                ),
                              )
                            : Text(
                                initial,
                                style: GoogleFonts.inter(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: gradColors[0],
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Match strength badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF059669)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${suggestion.theyTeachMe.length + suggestion.iTeachThem.length} skill overlap',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bio ────────────────────────────────────────────────
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Text(
                  user.bio,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ── They teach me ──────────────────────────────────────
            _SkillGroup(
              label: 'They can teach you',
              icon: Icons.school_outlined,
              color: _C.teachText,
              bgColor: _C.teachBg,
              skills: suggestion.theyTeachMe,
            ),

            const SizedBox(height: 12),

            // ── I teach them ───────────────────────────────────────
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

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'bottomnavbar.dart' show appScaffoldKey, SkillBridgeLogo;

// // ═══════════════════════════════════════════════════════════════════
// //  COLORS (standalone — no external import needed)
// // ═══════════════════════════════════════════════════════════════════

// class _C {
//   static const primary = Color(0xFF2563EB);
//   static const primaryDark = Color(0xFF1E40AF);
//   static const green = Color(0xFF059669);
//   static const surface = Color(0xFFFFFFFF);
//   static const background = Color(0xFFEEF2FF);
//   static const textDark = Color(0xFF0F172A);
//   static const textMid = Color(0xFF475569);
//   static const textLight = Color(0xFF94A3B8);
//   static const divider = Color(0xFFE2E8F0);
//   static const success = Color(0xFF10B981);
//   static const tag = Color(0xFFEFF6FF);
//   static const tagText = Color(0xFF3B82F6);
//   static const warning = Color(0xFFF59E0B);
//   static const warningBg = Color(0xFFFEF3C7);
//   static const gold = Color(0xFFFFD700);
//   static const goldDark = Color(0xFFB8860B);
//   static const red = Color(0xFFEF4444);
//   static const redLight = Color(0xFFFEE2E2);

//   static const gradStart = Color(0xFF2563EB);
//   static const gradEnd = Color(0xFF059669);

//   static const LinearGradient grad = LinearGradient(
//     colors: [gradStart, gradEnd],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static const LinearGradient pageBg = LinearGradient(
//     colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     stops: [0.0, 0.5, 1.0],
//   );
// }

// // ═══════════════════════════════════════════════════════════════════
// //  MODEL
// // ═══════════════════════════════════════════════════════════════════

// class _Person {
//   final String name, title, imageUrl, location, level, specialization, bio;
//   final double rating, pricePerHour;
//   final int reviews, experienceYears, maxSessionHours;
//   final List<String> skills;
//   final bool available, isPaid;

//   const _Person({
//     required this.name,
//     required this.title,
//     required this.imageUrl,
//     required this.location,
//     required this.level,
//     required this.specialization,
//     required this.bio,
//     required this.rating,
//     required this.pricePerHour,
//     required this.reviews,
//     required this.experienceYears,
//     required this.maxSessionHours,
//     required this.skills,
//     required this.available,
//     required this.isPaid,
//   });
// }

// // ═══════════════════════════════════════════════════════════════════
// //  DATA  — Learn + Teach pools
// // ═══════════════════════════════════════════════════════════════════

// const _learnPool = <_Person>[
//   _Person(
//     name: 'Marwan Hussien',
//     title: 'Senior Mobile Developer',
//     imageUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
//     location: 'Cairo, Egypt',
//     level: 'Senior',
//     specialization: 'Mobile Development',
//     bio:
//         'Lead Flutter engineer with 8 yrs building production apps. Passionate about clean architecture and performance.',
//     rating: 5.0,
//     pricePerHour: 120,
//     reviews: 450,
//     experienceYears: 8,
//     maxSessionHours: 3,
//     skills: ['Flutter', 'Dart', 'Firebase', 'iOS'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Mohamed Nukbassy',
//     title: 'Senior Data Analyst',
//     imageUrl: 'https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg',
//     location: 'Cairo, Egypt',
//     level: 'Senior',
//     specialization: 'Data Analysis',
//     bio:
//         'Expert in Python & Tableau. Helped 200+ students land data roles at top companies.',
//     rating: 4.9,
//     pricePerHour: 95,
//     reviews: 218,
//     experienceYears: 3,
//     maxSessionHours: 2,
//     skills: ['Python', 'SQL', 'Tableau', 'ML'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Sara Khalil',
//     title: 'UI/UX Designer',
//     imageUrl: 'https://i.pravatar.cc/300?img=47',
//     location: 'Alexandria, Egypt',
//     level: 'Mid',
//     specialization: 'UI/UX Design',
//     bio:
//         'Design systems enthusiast. Ex-Figma Community contributor. Makes every pixel count.',
//     rating: 4.8,
//     pricePerHour: 0,
//     reviews: 134,
//     experienceYears: 5,
//     maxSessionHours: 2,
//     skills: ['Figma', 'Sketch', 'Prototyping', 'Design Systems'],
//     available: false,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Ahmed Tarek',
//     title: 'Backend Engineer',
//     imageUrl: 'https://i.pravatar.cc/300?img=12',
//     location: 'Giza, Egypt',
//     level: 'Junior',
//     specialization: 'Backend Development',
//     bio:
//         'Node.js & PostgreSQL specialist. Loves teaching REST APIs and containerisation.',
//     rating: 4.7,
//     pricePerHour: 60,
//     reviews: 92,
//     experienceYears: 2,
//     maxSessionHours: 3,
//     skills: ['Node.js', 'PostgreSQL', 'Docker', 'AWS'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Layla Hassan',
//     title: 'AI & ML Engineer',
//     imageUrl: 'https://i.pravatar.cc/300?img=23',
//     location: 'Cairo, Egypt',
//     level: 'Mid',
//     specialization: 'Machine Learning',
//     bio:
//         'Researcher turned mentor. Specialises in NLP and computer vision with PyTorch.',
//     rating: 4.9,
//     pricePerHour: 110,
//     reviews: 176,
//     experienceYears: 4,
//     maxSessionHours: 3,
//     skills: ['Python', 'PyTorch', 'NLP', 'CV'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Daniel Osei',
//     title: 'Cloud Architect',
//     imageUrl: 'https://i.pravatar.cc/300?img=8',
//     location: 'Accra, Ghana',
//     level: 'Lead',
//     specialization: 'Cloud Computing',
//     bio:
//         'AWS & GCP certified. Designed infrastructure for 50+ startups across Africa.',
//     rating: 4.8,
//     pricePerHour: 140,
//     reviews: 203,
//     experienceYears: 7,
//     maxSessionHours: 2,
//     skills: ['AWS', 'GCP', 'Terraform', 'Kubernetes'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Sophie Martin',
//     title: 'Frontend Engineer',
//     imageUrl: 'https://i.pravatar.cc/300?img=32',
//     location: 'Paris, France',
//     level: 'Senior',
//     specialization: 'Web Development',
//     bio:
//         'React & Next.js expert. Loves accessibility and performance optimisation.',
//     rating: 4.7,
//     pricePerHour: 0,
//     reviews: 88,
//     experienceYears: 6,
//     maxSessionHours: 1,
//     skills: ['React', 'Next.js', 'TypeScript', 'CSS'],
//     available: false,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Carlos Mendez',
//     title: 'DevOps Engineer',
//     imageUrl: 'https://i.pravatar.cc/300?img=3',
//     location: 'Mexico City, Mexico',
//     level: 'Senior',
//     specialization: 'DevOps',
//     bio:
//         'CI/CD pipelines, Docker, k8s — turning chaos into smooth deployments.',
//     rating: 4.6,
//     pricePerHour: 80,
//     reviews: 115,
//     experienceYears: 5,
//     maxSessionHours: 2,
//     skills: ['Docker', 'Kubernetes', 'Jenkins', 'Linux'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Nadia Petrov',
//     title: 'iOS Developer',
//     imageUrl: 'https://i.pravatar.cc/300?img=44',
//     location: 'Moscow, Russia',
//     level: 'Senior',
//     specialization: 'Mobile Development',
//     bio: 'SwiftUI & UIKit veteran. Published 12 apps on the App Store.',
//     rating: 4.8,
//     pricePerHour: 100,
//     reviews: 159,
//     experienceYears: 7,
//     maxSessionHours: 3,
//     skills: ['Swift', 'SwiftUI', 'UIKit', 'Xcode'],
//     available: true,
//     isPaid: true,
//   ),
//   _Person(
//     name: 'Yusuf Al-Rashid',
//     title: 'Full-Stack Developer',
//     imageUrl: 'https://i.pravatar.cc/300?img=68',
//     location: 'Dubai, UAE',
//     level: 'Mid',
//     specialization: 'Web Development',
//     bio: 'MERN stack maestro. Passionate about GraphQL and real-time apps.',
//     rating: 4.5,
//     pricePerHour: 70,
//     reviews: 67,
//     experienceYears: 3,
//     maxSessionHours: 2,
//     skills: ['React', 'Node.js', 'GraphQL', 'MongoDB'],
//     available: true,
//     isPaid: true,
//   ),
// ];

// const _teachPool = <_Person>[
//   _Person(
//     name: 'Omar Fathy',
//     title: 'CS Student',
//     imageUrl: 'https://i.pravatar.cc/300?img=14',
//     location: 'Cairo, Egypt',
//     level: 'Junior',
//     specialization: 'Mobile Development',
//     bio: 'Learning Flutter & Dart. Building my first e-commerce app.',
//     rating: 4.2,
//     pricePerHour: 0,
//     reviews: 5,
//     experienceYears: 1,
//     maxSessionHours: 2,
//     skills: ['Flutter', 'Dart', 'Git'],
//     available: true,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Nada Sherif',
//     title: 'Junior Data Analyst',
//     imageUrl: 'https://i.pravatar.cc/300?img=45',
//     location: 'Alexandria, Egypt',
//     level: 'Junior',
//     specialization: 'Data Analysis',
//     bio:
//         'Excel wizard transitioning to Python & SQL. Eager to learn visualization.',
//     rating: 4.0,
//     pricePerHour: 0,
//     reviews: 3,
//     experienceYears: 1,
//     maxSessionHours: 1,
//     skills: ['Excel', 'Python Basics', 'SQL Basics'],
//     available: true,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Hassan Ramzy',
//     title: 'Self-Taught Developer',
//     imageUrl: 'https://i.pravatar.cc/300?img=16',
//     location: 'Giza, Egypt',
//     level: 'Mid',
//     specialization: 'Backend Development',
//     bio:
//         'Built 3 small Node.js projects. Wants to master system design and Docker.',
//     rating: 4.3,
//     pricePerHour: 0,
//     reviews: 8,
//     experienceYears: 2,
//     maxSessionHours: 2,
//     skills: ['Node.js', 'Express', 'MySQL'],
//     available: true,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Dina Samir',
//     title: 'Design Student',
//     imageUrl: 'https://i.pravatar.cc/300?img=43',
//     location: 'Cairo, Egypt',
//     level: 'Junior',
//     specialization: 'UI/UX Design',
//     bio:
//         'Studying graphic design. Learning Figma to transition into product design.',
//     rating: 4.1,
//     pricePerHour: 0,
//     reviews: 4,
//     experienceYears: 1,
//     maxSessionHours: 1,
//     skills: ['Figma Basics', 'Canva', 'Illustration'],
//     available: false,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Karim Nour',
//     title: 'ML Enthusiast',
//     imageUrl: 'https://i.pravatar.cc/300?img=13',
//     location: 'Cairo, Egypt',
//     level: 'Junior',
//     specialization: 'Machine Learning',
//     bio: 'Math background, learning ML theory and Scikit-learn from scratch.',
//     rating: 4.4,
//     pricePerHour: 0,
//     reviews: 6,
//     experienceYears: 1,
//     maxSessionHours: 3,
//     skills: ['Python', 'Scikit-learn', 'NumPy'],
//     available: true,
//     isPaid: false,
//   ),
//   _Person(
//     name: 'Mona Adel',
//     title: 'Career Changer',
//     imageUrl: 'https://i.pravatar.cc/300?img=44',
//     location: 'Cairo, Egypt',
//     level: 'Junior',
//     specialization: 'Web Development',
//     bio:
//         'Marketing background. Learning React to pivot into frontend development.',
//     rating: 4.0,
//     pricePerHour: 0,
//     reviews: 2,
//     experienceYears: 1,
//     maxSessionHours: 2,
//     skills: ['HTML', 'CSS', 'React Basics'],
//     available: true,
//     isPaid: false,
//   ),
// ];

// // Favourites store (simple in-memory set)
// final _favourites = <String>{};

// // ═══════════════════════════════════════════════════════════════════
// //  MATCH PAGE
// // ═══════════════════════════════════════════════════════════════════

// class MatchPage extends StatefulWidget {
//   const MatchPage({super.key});
//   @override
//   State<MatchPage> createState() => _MatchPageState();
// }

// class _MatchPageState extends State<MatchPage> {
//   int _modeIndex = 0; // 0 = Learn, 1 = Teach
//   int _cardIndex = 0;
//   bool _showFilter = false;

//   // filter state
//   String? _filterSpec;
//   String? _filterLevel;
//   double _filterMinRating = 4.0;
//   String? _filterPricing;

//   List<_Person> get _pool => _modeIndex == 0 ? _learnPool : _teachPool;

//   List<_Person> get _filtered {
//     return _pool.where((p) {
//       final matchSpec = _filterSpec == null || p.specialization == _filterSpec;
//       final matchLevel = _filterLevel == null || p.level == _filterLevel;
//       final matchRating = p.rating >= _filterMinRating;
//       final matchPricing =
//           _filterPricing == null ||
//           (_filterPricing == 'Paid' && p.isPaid) ||
//           (_filterPricing == 'Free' && !p.isPaid);
//       return matchSpec && matchLevel && matchRating && matchPricing;
//     }).toList();
//   }

//   _Person? get _current {
//     final f = _filtered;
//     if (f.isEmpty || _cardIndex >= f.length) return null;
//     return f[_cardIndex];
//   }

//   void _next() =>
//       setState(() => _cardIndex = (_cardIndex + 1).clamp(0, _filtered.length));
//   void _prev() =>
//       setState(() => _cardIndex = (_cardIndex - 1).clamp(0, _filtered.length));

//   void _dismiss() => _next();

//   void _like() {
//     final p = _current;
//     if (p == null) return;
//     _showMatchSheet(p);
//   }

//   void _heart() {
//     final p = _current;
//     if (p == null) return;
//     setState(() {
//       if (_favourites.contains(p.name)) {
//         _favourites.remove(p.name);
//       } else {
//         _favourites.add(p.name);
//       }
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _favourites.contains(p.name)
//               ? '❤️ ${p.name} added to favourites!'
//               : '💔 ${p.name} removed from favourites.',
//         ),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _C.primary,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // ── Match / Book sheet ─────────────────────────────────────────

//   void _showMatchSheet(_Person p) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _MatchSheet(person: p, onBooked: _next),
//     );
//   }

//   // ── Filter bottom sheet ────────────────────────────────────────

//   void _openFilter() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setS) {
//           final specs = (_modeIndex == 0 ? _learnPool : _teachPool)
//               .map((p) => p.specialization)
//               .toSet()
//               .toList();
//           return Container(
//             height: MediaQuery.of(ctx).size.height * 0.80,
//             decoration: const BoxDecoration(
//               color: _C.surface,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//             ),
//             child: Column(
//               children: [
//                 // Handle
//                 Container(
//                   margin: const EdgeInsets.only(top: 12),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: _C.divider,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           gradient: _C.grad,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.tune_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Filter',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: _C.textDark,
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {
//                           setS(() {
//                             _filterSpec = null;
//                             _filterLevel = null;
//                             _filterMinRating = 4.0;
//                             _filterPricing = null;
//                             _cardIndex = 0;
//                           });
//                           setState(() {});
//                         },
//                         child: const Text(
//                           'Reset',
//                           style: TextStyle(
//                             color: _C.primary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 24),
//                 Expanded(
//                   child: ListView(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     children: [
//                       // Mode toggle inside filter
//                       _FSection(
//                         icon: Icons.compare_arrows_rounded,
//                         title: 'Mode',
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: _FChip(
//                                 label: '📚 Learn',
//                                 selected: _modeIndex == 0,
//                                 onTap: () => setS(() {
//                                   _modeIndex = 0;
//                                   _cardIndex = 0;
//                                   setState(() {});
//                                 }),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: _FChip(
//                                 label: '🎓 Teach',
//                                 selected: _modeIndex == 1,
//                                 onTap: () => setS(() {
//                                   _modeIndex = 1;
//                                   _cardIndex = 0;
//                                   setState(() {});
//                                 }),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Specialization
//                       _FSection(
//                         icon: Icons.code_rounded,
//                         title: 'Specialization',
//                         child: Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: specs.map((s) {
//                             final sel = _filterSpec == s;
//                             return _FChip(
//                               label: s,
//                               selected: sel,
//                               onTap: () => setS(() {
//                                 _filterSpec = sel ? null : s;
//                                 _cardIndex = 0;
//                                 setState(() {});
//                               }),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Level
//                       _FSection(
//                         icon: Icons.workspace_premium_rounded,
//                         title: 'Level',
//                         child: Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: ['Junior', 'Mid', 'Senior', 'Lead'].map((
//                             l,
//                           ) {
//                             final sel = _filterLevel == l;
//                             return _FChip(
//                               label: l,
//                               selected: sel,
//                               onTap: () => setS(() {
//                                 _filterLevel = sel ? null : l;
//                                 _cardIndex = 0;
//                                 setState(() {});
//                               }),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Rating
//                       _FSection(
//                         icon: Icons.star_rounded,
//                         title: 'Min Rating',
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.star_rounded,
//                                   color: _C.gold,
//                                   size: 18,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   _filterMinRating.toStringAsFixed(1),
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w800,
//                                     color: _C.primary,
//                                   ),
//                                 ),
//                                 const Text(
//                                   ' and above',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: _C.textMid,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SliderTheme(
//                               data: SliderThemeData(
//                                 activeTrackColor: _C.primary,
//                                 thumbColor: _C.primary,
//                                 overlayColor: _C.primary.withOpacity(0.1),
//                                 inactiveTrackColor: _C.divider,
//                               ),
//                               child: Slider(
//                                 value: _filterMinRating,
//                                 min: 4.0,
//                                 max: 5.0,
//                                 divisions: 10,
//                                 onChanged: (v) => setS(() {
//                                   _filterMinRating = v;
//                                   _cardIndex = 0;
//                                   setState(() {});
//                                 }),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Pricing (only for Learn mode)
//                       if (_modeIndex == 0)
//                         _FSection(
//                           icon: Icons.attach_money_rounded,
//                           title: 'Session Type',
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: _FChip(
//                                   label: '💰 Paid',
//                                   selected: _filterPricing == 'Paid',
//                                   onTap: () => setS(() {
//                                     _filterPricing = _filterPricing == 'Paid'
//                                         ? null
//                                         : 'Paid';
//                                     _cardIndex = 0;
//                                     setState(() {});
//                                   }),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: _FChip(
//                                   label: '🆓 Free',
//                                   selected: _filterPricing == 'Free',
//                                   onTap: () => setS(() {
//                                     _filterPricing = _filterPricing == 'Free'
//                                         ? null
//                                         : 'Free';
//                                     _cardIndex = 0;
//                                     setState(() {});
//                                   }),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//                 // Apply
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(ctx),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       decoration: BoxDecoration(
//                         gradient: _C.grad,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Show ${_filtered.length} Results',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── build ──────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final person = _current;
//     final isEmpty = person == null;

//     return Scaffold(
//       backgroundColor: _C.background,
//       body: Container(
//         decoration: const BoxDecoration(gradient: _C.pageBg),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               const SizedBox(height: 8),
//               _buildModeToggle(),
//               const SizedBox(height: 16),
//               Expanded(child: isEmpty ? _buildEmpty() : _buildCard(person)),
//               if (!isEmpty) _buildActions(person),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── AppBar ──────────────────────────────────────────────────────

//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: _C.surface.withOpacity(0.9),
//         border: Border(bottom: BorderSide(color: _C.divider.withOpacity(0.5))),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => appScaffoldKey.currentState?.openDrawer(),
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     _C.primary.withOpacity(0.1),
//                     _C.green.withOpacity(0.1),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _C.primary.withOpacity(0.2)),
//               ),
//               child: const Icon(
//                 Icons.menu_rounded,
//                 size: 20,
//                 color: _C.primary,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           const SkillBridgeLogo(fontSize: 20),
//           const Spacer(),
//           // Filter
//           GestureDetector(
//             onTap: _openFilter,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 gradient: _C.grad,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _C.primary.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.tune_rounded,
//                 size: 20,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Favourites
//           GestureDetector(
//             onTap: _showFavourites,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         _C.primary.withOpacity(0.1),
//                         _C.green.withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: _C.primary.withOpacity(0.2)),
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border_rounded,
//                     size: 20,
//                     color: _C.primary,
//                   ),
//                 ),
//                 if (_favourites.isNotEmpty)
//                   Positioned(
//                     top: -4,
//                     right: -4,
//                     child: Container(
//                       width: 17,
//                       height: 17,
//                       decoration: BoxDecoration(
//                         gradient: _C.grad,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${_favourites.length}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 9,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFavourites() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         height: 340,
//         decoration: const BoxDecoration(
//           color: _C.surface,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: _C.divider,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       gradient: _C.grad,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.favorite_rounded,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Favourites (${_favourites.length})',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: _C.textDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 20),
//             Expanded(
//               child: _favourites.isEmpty
//                   ? const Center(
//                       child: Text(
//                         'No favourites yet ❤️',
//                         style: TextStyle(color: _C.textLight),
//                       ),
//                     )
//                   : ListView(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       children: _favourites.map((name) {
//                         final all = [..._learnPool, ..._teachPool];
//                         final p = all.firstWhere(
//                           (x) => x.name == name,
//                           orElse: () => _learnPool.first,
//                         );
//                         return ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               p.imageUrl,
//                               width: 44,
//                               height: 44,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                 width: 44,
//                                 height: 44,
//                                 color: _C.tag,
//                                 child: const Icon(
//                                   Icons.person,
//                                   color: _C.primary,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: _C.textDark,
//                             ),
//                           ),
//                           subtitle: Text(
//                             p.specialization,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: _C.textMid,
//                             ),
//                           ),
//                           trailing: GestureDetector(
//                             onTap: () => setState(() {
//                               _favourites.remove(name);
//                               Navigator.pop(context);
//                             }),
//                             child: const Icon(
//                               Icons.close,
//                               size: 18,
//                               color: _C.textLight,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Mode Toggle ─────────────────────────────────────────────────

//   Widget _buildModeToggle() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: _C.divider),
//       ),
//       child: Row(
//         children: [
//           _ModeTab(
//             label: '📚 I Want to Learn',
//             isActive: _modeIndex == 0,
//             onTap: () => setState(() {
//               _modeIndex = 0;
//               _cardIndex = 0;
//             }),
//           ),
//           _ModeTab(
//             label: '🎓 I Want to Teach',
//             isActive: _modeIndex == 1,
//             onTap: () => setState(() {
//               _modeIndex = 1;
//               _cardIndex = 0;
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Empty state ─────────────────────────────────────────────────

//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: _C.grad,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: const Icon(
//               Icons.people_outline_rounded,
//               size: 40,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No more matches!',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: _C.textDark,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Try adjusting your filters.',
//             style: TextStyle(fontSize: 14, color: _C.textMid),
//           ),
//           const SizedBox(height: 24),
//           GestureDetector(
//             onTap: () => setState(() {
//               _cardIndex = 0;
//             }),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
//               decoration: BoxDecoration(
//                 gradient: _C.grad,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 'Start Over',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Profile Card ────────────────────────────────────────────────

//   Widget _buildCard(_Person p) {
//     final isFav = _favourites.contains(p.name);
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A1A2E),
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(color: _C.green.withOpacity(0.4), width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: _C.primary.withOpacity(0.2),
//               blurRadius: 30,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(28),
//           child: Stack(
//             children: [
//               // BG gradient
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topRight,
//                       end: Alignment.bottomLeft,
//                       colors: [
//                         _C.green.withOpacity(0.1),
//                         Colors.transparent,
//                         _C.primary.withOpacity(0.08),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               // Photo
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Image.network(
//                     p.imageUrl,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: _C.tag,
//                       child: const Center(
//                         child: Icon(
//                           Icons.person_rounded,
//                           size: 80,
//                           color: _C.primary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Dark gradient overlay
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Colors.transparent,
//                         Colors.black.withOpacity(0.7),
//                         Colors.black.withOpacity(0.95),
//                       ],
//                       stops: const [0.0, 0.25, 0.55, 1.0],
//                     ),
//                   ),
//                 ),
//               ),

//               // Top badges
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 child: p.rating >= 4.9
//                     ? Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.workspace_premium_rounded,
//                               color: Colors.white,
//                               size: 12,
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Top Rated',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),

//               // Heart (favourite) — top right
//               Positioned(
//                 top: 16,
//                 right: 16,
//                 child: GestureDetector(
//                   onTap: _heart,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: isFav
//                           ? Colors.red.withOpacity(0.9)
//                           : Colors.black.withOpacity(0.4),
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     child: Icon(
//                       isFav
//                           ? Icons.favorite_rounded
//                           : Icons.favorite_border_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),

//               // Content at bottom
//               Positioned.fill(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Name + rating
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               '${p.name}, ${p.experienceYears + 22}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 height: 1.1,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.5),
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.star_rounded,
//                                   color: _C.gold,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   p.rating.toStringAsFixed(1),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const Text(
//                                   'RATING',
//                                   style: TextStyle(
//                                     color: _C.textLight,
//                                     fontSize: 7,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       // Location + level
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on_outlined,
//                             color: _C.textLight,
//                             size: 13,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             p.location,
//                             style: const TextStyle(
//                               color: _C.textLight,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: _C.grad,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               p.level,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // Skills
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 6,
//                         children: p.skills
//                             .map(
//                               (s) => Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.2),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   s,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                       const SizedBox(height: 10),
//                       // Price + session length + available
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: p.isPaid
//                                   ? _C.primary.withOpacity(0.85)
//                                   : _C.green.withOpacity(0.85),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               p.isPaid
//                                   ? '\$${p.pricePerHour.toInt()}/hr'
//                                   : 'FREE',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.2),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.access_time_rounded,
//                                   color: Colors.white70,
//                                   size: 12,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Max ${p.maxSessionHours}h session',
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (p.available) ...[
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _C.success.withOpacity(0.85),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.circle,
//                                     color: Colors.white,
//                                     size: 6,
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'Available',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // Bio
//                       Text(
//                         p.bio,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.75),
//                           fontSize: 12,
//                           height: 1.5,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       // Card progress
//                       Text(
//                         '${_cardIndex + 1} / ${_filtered.length}',
//                         style: const TextStyle(
//                           color: _C.textLight,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Action Buttons (UI-polished: X | gradient-refresh | check) ──

//   Widget _buildActions(_Person p) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // ✗ Dismiss — white card circle with red icon
//           _ActionBtn(
//             onTap: _dismiss,
//             size: 56,
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _C.surface,
//                 border: Border.all(color: _C.divider),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(Icons.close_rounded, color: _C.red, size: 26),
//             ),
//           ),

//           const SizedBox(width: 24),

//           // 🔄 Center — large gradient circle (go back / prev)
//           _ActionBtn(
//             onTap: _cardIndex > 0 ? _prev : null,
//             size: 68,
//             child: Container(
//               width: 68,
//               height: 68,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [_C.gradStart, _C.gradEnd],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _C.primary.withOpacity(0.4),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.refresh_rounded,
//                 color: Colors.white,
//                 size: 30,
//               ),
//             ),
//           ),

//           const SizedBox(width: 24),

//           // ✓ Like / Match — white card circle with green icon
//           _ActionBtn(
//             onTap: _like,
//             size: 56,
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _C.surface,
//                 border: Border.all(color: _C.divider),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.check_rounded,
//                 color: _C.success,
//                 size: 26,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  ACTION BUTTON WRAPPER
// // ─────────────────────────────────────────────────────────────────

// class _ActionBtn extends StatelessWidget {
//   final VoidCallback? onTap;
//   final Widget child;
//   final double size;
//   const _ActionBtn({
//     required this.onTap,
//     required this.child,
//     required this.size,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Opacity(opacity: onTap == null ? 0.4 : 1.0, child: child),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  MODE TAB
// // ─────────────────────────────────────────────────────────────────

// class _ModeTab extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final VoidCallback onTap;
//   const _ModeTab({
//     required this.label,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             gradient: isActive ? _C.grad : null,
//             borderRadius: BorderRadius.circular(26),
//             boxShadow: isActive
//                 ? [
//                     BoxShadow(
//                       color: _C.primary.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isActive ? Colors.white : _C.textMid,
//               fontWeight: FontWeight.w600,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  FILTER SECTION & CHIP
// // ─────────────────────────────────────────────────────────────────

// class _FSection extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Widget child;
//   const _FSection({
//     required this.icon,
//     required this.title,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 gradient: _C.grad,
//                 borderRadius: BorderRadius.circular(9),
//               ),
//               child: Icon(icon, color: Colors.white, size: 16),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: _C.textDark,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         child,
//       ],
//     );
//   }
// }

// class _FChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//   const _FChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//           gradient: selected ? _C.grad : null,
//           color: selected ? null : const Color(0xFFEEF2FF),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: selected ? Colors.transparent : _C.divider),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: _C.primary.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
//             color: selected ? Colors.white : _C.textMid,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  MATCH SHEET  (check availability + book)
// // ─────────────────────────────────────────────────────────────────

// class _MatchSheet extends StatefulWidget {
//   final _Person person;
//   final VoidCallback onBooked;
//   const _MatchSheet({required this.person, required this.onBooked});

//   @override
//   State<_MatchSheet> createState() => _MatchSheetState();
// }

// class _MatchSheetState extends State<_MatchSheet> {
//   final _msgCtrl = TextEditingController();
//   bool _available = true;
//   DateTime? _pickedDate;
//   TimeOfDay? _pickedTime;
//   int _sessionHrs = 1;
//   bool _booked = false;

//   @override
//   void dispose() {
//     _msgCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: _C.primary,
//             onPrimary: Colors.white,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (d != null) setState(() => _pickedDate = d);
//   }

//   Future<void> _pickTime() async {
//     final t = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 10, minute: 0),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(
//           ctx,
//         ).copyWith(colorScheme: const ColorScheme.light(primary: _C.primary)),
//         child: child!,
//       ),
//     );
//     if (t != null) setState(() => _pickedTime = t);
//   }

//   String _fmt(DateTime d) {
//     const m = [
//       '',
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${m[d.month]} ${d.day}, ${d.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final p = widget.person;
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       decoration: const BoxDecoration(
//         color: _C.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: _booked ? _buildSuccess(p) : _buildForm(p),
//       ),
//     );
//   }

//   Widget _buildSuccess(_Person p) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 16),
//         Container(
//           width: 72,
//           height: 72,
//           decoration: BoxDecoration(gradient: _C.grad, shape: BoxShape.circle),
//           child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Session Booked! 🎉',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//             color: _C.textDark,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Your session with ${p.name.split(' ').first} is confirmed.\nThey\'ll receive your message shortly.',
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 13, color: _C.textMid, height: 1.5),
//         ),
//         const SizedBox(height: 24),
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//             widget.onBooked();
//           },
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(
//               gradient: _C.grad,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Center(
//               child: Text(
//                 'Continue Matching',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildForm(_Person p) {
//     final canBook = _pickedDate != null && _pickedTime != null;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Handle
//         Center(
//           child: Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: _C.divider,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         // Person header
//         Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(14),
//               child: Image.network(
//                 p.imageUrl,
//                 width: 56,
//                 height: 56,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   width: 56,
//                   height: 56,
//                   color: _C.tag,
//                   child: const Icon(Icons.person, color: _C.primary),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     p.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: _C.textDark,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     p.title,
//                     style: const TextStyle(fontSize: 12, color: _C.textMid),
//                   ),
//                   const SizedBox(height: 5),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           color: p.isPaid
//                               ? _C.primary.withOpacity(0.1)
//                               : _C.green.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           p.isPaid ? '\$${p.pricePerHour.toInt()}/hr' : 'FREE',
//                           style: TextStyle(
//                             color: p.isPaid ? _C.primary : _C.green,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 3,
//                         ),
//                         decoration: BoxDecoration(
//                           color: p.available
//                               ? _C.success.withOpacity(0.1)
//                               : _C.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.circle,
//                               size: 6,
//                               color: p.available ? _C.success : _C.red,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               p.available ? 'Available Now' : 'Busy',
//                               style: TextStyle(
//                                 color: p.available ? _C.success : _C.red,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 20),
//         Container(height: 1, color: _C.divider),
//         const SizedBox(height: 20),

//         // Session duration
//         Align(
//           alignment: Alignment.centerLeft,
//           child: const Text(
//             'Session Duration',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _C.textDark,
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: List.generate(p.maxSessionHours, (i) {
//             final hrs = i + 1;
//             final sel = _sessionHrs == hrs;
//             return GestureDetector(
//               onTap: () => setState(() => _sessionHrs = hrs),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.only(right: 8),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 9,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: sel ? _C.grad : null,
//                   color: sel ? null : _C.background,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: sel ? Colors.transparent : _C.divider,
//                   ),
//                 ),
//                 child: Text(
//                   '${hrs}h',
//                   style: TextStyle(
//                     color: sel ? Colors.white : _C.textMid,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),

//         const SizedBox(height: 16),

//         // Date
//         Align(
//           alignment: Alignment.centerLeft,
//           child: const Text(
//             'Select Date',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _C.textDark,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: _pickDate,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _pickedDate != null ? _C.primary : _C.divider,
//               ),
//               borderRadius: BorderRadius.circular(14),
//               color: _pickedDate != null ? _C.tag : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today_rounded,
//                   size: 16,
//                   color: _pickedDate != null ? _C.primary : _C.textLight,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   _pickedDate != null ? _fmt(_pickedDate!) : 'Choose a date',
//                   style: TextStyle(
//                     color: _pickedDate != null ? _C.primary : _C.textLight,
//                     fontWeight: _pickedDate != null
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         // Time
//         Align(
//           alignment: Alignment.centerLeft,
//           child: const Text(
//             'Select Time',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _C.textDark,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: _pickTime,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _pickedTime != null ? _C.primary : _C.divider,
//               ),
//               borderRadius: BorderRadius.circular(14),
//               color: _pickedTime != null ? _C.tag : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.access_time_rounded,
//                   size: 16,
//                   color: _pickedTime != null ? _C.primary : _C.textLight,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   _pickedTime != null
//                       ? _pickedTime!.format(context)
//                       : 'Choose a time',
//                   style: TextStyle(
//                     color: _pickedTime != null ? _C.primary : _C.textLight,
//                     fontWeight: _pickedTime != null
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Message
//         Align(
//           alignment: Alignment.centerLeft,
//           child: const Text(
//             'Your Message',
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _C.textDark,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: _C.background,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: _C.divider),
//           ),
//           child: TextField(
//             controller: _msgCtrl,
//             maxLines: 3,
//             decoration: const InputDecoration(
//               hintText: 'Introduce yourself and say what you want to learn...',
//               hintStyle: TextStyle(color: _C.textLight, fontSize: 13),
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.all(14),
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Book button
//         GestureDetector(
//           onTap: canBook ? () => setState(() => _booked = true) : null,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             decoration: BoxDecoration(
//               gradient: canBook ? _C.grad : null,
//               color: canBook ? null : _C.divider,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Center(
//               child: Text(
//                 canBook
//                     ? 'Book Session with ${p.name.split(' ').first}'
//                     : 'Pick date & time to book',
//                 style: TextStyle(
//                   color: canBook ? Colors.white : _C.textLight,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: const Center(
//             child: Text(
//               'Maybe Later',
//               style: TextStyle(color: _C.textLight, fontSize: 13),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }
