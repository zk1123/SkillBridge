import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'ai_chat_screen.dart';
import 'app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;
  String _searchQuery = '';

  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color logoBlue = Color(0xFF3953E8);
  static const Color logoTeal = Color(0xFF3AAFA9);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch the other user's data from a chat document
  Future<Map<String, dynamic>?> _getOtherUser(
    Map<String, dynamic> chatData,
  ) async {
    final otherUid = chatData['userAId'] == _currentUid
        ? chatData['userBId']
        : chatData['userAId'];
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'chatId': chatData['chatId']};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar — unchanged ────────────────────────────
                const SkillBridgeAppBar(),

                // ── Header — matches Sessions page exactly ─────────
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
                        'Messages',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your peer-to-peer conversations.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search bar ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F2F6),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // thin divider under search
                Container(height: 1, color: const Color(0xFFE5E7EB)),

                // ── Chat list — backend untouched ──────────────────
                Expanded(child: _buildChatList()),
              ],
            ),

            // ── AI Chat FAB — completely untouched ─────────────────
            Positioned(
              right: 16,
              bottom: 90,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF005DA7), Color(0xFF2976C7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0060AC).withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    // Stream chats where current user is userAId OR userBId
    final streamA = FirebaseFirestore.instance
        .collection('chats')
        .where('userAId', isEqualTo: _currentUid)
        .snapshots();

    final streamB = FirebaseFirestore.instance
        .collection('chats')
        .where('userBId', isEqualTo: _currentUid)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: streamA,
      builder: (context, snapshotA) {
        return StreamBuilder<QuerySnapshot>(
          stream: streamB,
          builder: (context, snapshotB) {
            if (snapshotA.connectionState == ConnectionState.waiting ||
                snapshotB.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF005DA7)),
                ),
              );
            }

            // Merge both streams
            final allDocs = [
              ...?snapshotA.data?.docs,
              ...?snapshotB.data?.docs,
            ];

            if (allDocs.isEmpty) {
              return _buildEmptyState();
            }

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _resolveChats(allDocs),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF005DA7),
                      ),
                    ),
                  );
                }

                final chats = snapshot.data!
                    .where(
                      (c) =>
                          _searchQuery.isEmpty ||
                          (c['name'] as String).toLowerCase().contains(
                            _searchQuery,
                          ),
                    )
                    .toList();

                if (chats.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: chats
                      .map((chat) => _buildConversationItem(chat))
                      .toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _resolveChats(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final results = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final data = {...doc.data() as Map<String, dynamic>, 'chatId': doc.id};
      final otherUser = await _getOtherUser(data);
      if (otherUser != null) {
        final otherUid = otherUser['uid'] as String;

        // Fetch matchId for this pair
        String matchId = '';
        final matchSnap = await FirebaseFirestore.instance
            .collection('matches')
            .where('userAId', isEqualTo: _currentUid)
            .where('userBId', isEqualTo: otherUid)
            .where('status', isEqualTo: 'matched')
            .limit(1)
            .get();
        if (matchSnap.docs.isNotEmpty) {
          matchId = matchSnap.docs.first.id;
        } else {
          final reverseSnap = await FirebaseFirestore.instance
              .collection('matches')
              .where('userAId', isEqualTo: otherUid)
              .where('userBId', isEqualTo: _currentUid)
              .where('status', isEqualTo: 'matched')
              .limit(1)
              .get();
          if (reverseSnap.docs.isNotEmpty) {
            matchId = reverseSnap.docs.first.id;
          }
        }

        results.add({
          'chatId': doc.id,
          'name': otherUser['name'] ?? 'Unknown',
          'profilePicUrl': otherUser['profilePicUrl'] ?? '',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageAt': data['lastMessageAt'],
          'otherUid': otherUid,
          'matchId': matchId, // ← stored here
        });
      }
    }
    results.sort((a, b) {
      final aTime = a['lastMessageAt'] as Timestamp?;
      final bTime = b['lastMessageAt'] as Timestamp?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return results;
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 36,
                color: Color(0xFF005DA7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191C21),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Match with someone to start chatting!',
              style: TextStyle(fontSize: 13, color: Color(0xFF717783)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> chat) {
    // ── Data extraction — completely unchanged ──────────────────────
    final String name = chat['name'];
    final String profilePicUrl = chat['profilePicUrl'];
    final String lastMessage = chat['lastMessage'];
    final String chatId = chat['chatId'];
    final String otherUid = chat['otherUid'];
    final bool hasPhoto = profilePicUrl.isNotEmpty;
    final String matchId = chat['matchId'] ?? '';

    // TODO: replace with chat['unreadCount'] as int? ?? 0  when added to stream
    final int unreadCount = 0;
    final bool hasUnread = unreadCount > 0;

    // ── Gradient sets for avatar frame — cycles by name initial ────
    const List<List<Color>> _avatarGradients = [
      [Color(0xFF1E40AF), Color(0xFF2563EB)], // blue
      [Color(0xFF059669), Color(0xFF34D399)], // green
      [Color(0xFF7C3AED), Color(0xFFA78BFA)], // purple
      [Color(0xFFD97706), Color(0xFFFBBF24)], // amber
      [Color(0xFF2563EB), Color(0xFF059669)], // blue→green
    ];
    final gradientColors =
        _avatarGradients[name.codeUnitAt(0) % _avatarGradients.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: hasUnread ? 3 : 1,
        shadowColor: hasUnread
            ? const Color(0xFF2563EB).withOpacity(0.15)
            : Colors.black.withOpacity(0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  chatId: chatId,
                  matchId: matchId,
                  otherUid: otherUid,
                  name: name,
                  profilePicUrl: profilePicUrl,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Avatar with gradient ring ───────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gradient ring
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: hasPhoto
                              ? ClipOval(
                                  child: Image.network(
                                    profilePicUrl,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      name[0].toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: gradientColors[0],
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  name[0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: gradientColors[0],
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // ── Unread badge dot ──────────────────────────
                    if (hasUnread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // ── Name + last message ─────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                fontSize: 15,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          // ── Unread chip ─────────────────────────
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$unreadCount new',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lastMessage.isEmpty ? 'Say hello 👋' : lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: lastMessage.isEmpty
                              ? const Color(0xFF2563EB)
                              : hasUnread
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFF6B7280),
                          fontStyle: lastMessage.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Chevron ─────────────────────────────────────────
                Icon(
                  Icons.chevron_right_rounded,
                  color: hasUnread
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
