import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'ai_chat_screen.dart';

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
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: const Icon(Icons.menu, color: textPrimary),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [logoBlue, logoTeal],
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
          Icon(Icons.search, color: textPrimary),
          SizedBox(width: 12),
          Icon(Icons.person_outline, color: textPrimary),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF191C21),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: const TextStyle(color: Color(0xFF717783)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF717783),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF005DA7),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Real-time chat list
                      _buildChatList(),
                    ]),
                  ),
                ),
              ],
            ),

            // AI Chat FAB — untouched
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
    final String name = chat['name'];
    final String profilePicUrl = chat['profilePicUrl'];
    final String lastMessage = chat['lastMessage'];
    final String chatId = chat['chatId'];
    final String otherUid = chat['otherUid'];
    final bool hasPhoto = profilePicUrl.isNotEmpty;
    final String matchId = chat['matchId'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFD4E3FF),
                  child: hasPhoto
                      ? ClipOval(
                          child: Image.network(
                            profilePicUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF2976C7),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2976C7),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF191C21),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage.isEmpty ? 'Say hello 👋' : lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: lastMessage.isEmpty
                              ? const Color(0xFF005DA7)
                              : const Color(0xFF414751),
                          fontStyle: lastMessage.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
