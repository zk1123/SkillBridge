import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/block_model.dart';
import '../services/block_service.dart';
import 'package:provider/provider.dart';
import '../providers/block_provider.dart';

class BlockedAccountsPage extends StatefulWidget {
  const BlockedAccountsPage({super.key});

  @override
  State<BlockedAccountsPage> createState() => _BlockedAccountsPageState();
}

class _BlockedAccountsPageState extends State<BlockedAccountsPage> {
  final BlockService _blockService = BlockService();

  List<BlockedUserDetail> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  // tracks which card is showing the confirm box
  String? _confirmingId;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _blockService.getBlockedUsersWithDetails();
      setState(() {
        _blockedUsers = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load blocked users. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _toggleConfirm(String uid) {
    setState(() {
      _confirmingId = (_confirmingId == uid) ? null : uid;
    });
  }

  Future<void> _unblockUser(String uid) async {
    try {
      await context.read<BlockProvider>().unblockUser(uid);
      setState(() {
        _blockedUsers.removeWhere((d) => d.user.uid == uid);
        _confirmingId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unblock user. Try again.')),
      );
    }
  }

  String _formatDate(Timestamp ts) {
    final dt = ts.toDate();
    return DateFormat('d/M/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9A7), Color(0xFF4A6CF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Skill',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Bridge',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 12),
                    const Icon(Icons.person_outline, color: Colors.white),
                  ],
                ),
              ),

              // ── Title ────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blocked Accounts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadBlockedUsers,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return const Center(
        child: Text(
          'No blocked accounts',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _blockedUsers.length,
      itemBuilder: (context, index) {
        final detail = _blockedUsers[index];
        final uid = detail.user.uid;
        final isConfirming = _confirmingId == uid;

        return Column(
          children: [
            // ── User Card ─────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C9A7), Color(0xFF4A6CF7)],
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: detail.user.profilePicUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              detail.user.profilePicUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarFallback(detail.user.name),
                            ),
                          )
                        : _avatarFallback(detail.user.name),
                  ),
                  const SizedBox(width: 12),

                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Blocked on: ${_formatDate(detail.block.createdAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unblock button
                  GestureDetector(
                    onTap: () => _toggleConfirm(uid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isConfirming
                            ? const Color(0xFFFF6B6B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isConfirming ? 'Cancel' : 'Unblock',
                        style: TextStyle(
                          color: isConfirming
                              ? Colors.white
                              : const Color(0xFF4A6CF7),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Confirm Box ───────────────────────────
            if (isConfirming)
              Container(
                margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.block,
                        color: Color(0xFFFF6B6B),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to unblock ${detail.user.name}?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        // Yes
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _unblockUser(uid),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C9A7),
                                    Color(0xFF4A6CF7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Yes, Unblock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // No
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleConfirm(uid),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Text(
                                  'No, Cancel',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _avatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
