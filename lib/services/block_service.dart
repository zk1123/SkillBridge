import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/block_model.dart';
import '../models/user_model.dart';

class BlockService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser!.uid;

  // ─── Block a user ─────────────────────────────────────────
  Future<void> blockUser(String targetUserId) async {
    final blockId = '${_currentUserId}_$targetUserId';
    final block = BlockModel(
      blockId: blockId,
      blockerId: _currentUserId,
      blockedId: targetUserId,
      createdAt: Timestamp.now(), // ← fix
    );
    await _firestore.collection('blocks').doc(blockId).set(block.toMap());
  }

  // ─── Unblock a user ───────────────────────────────────────
  Future<void> unblockUser(String targetUserId) async {
    final blockId = '${_currentUserId}_$targetUserId';
    await _firestore.collection('blocks').doc(blockId).delete();
  }

  // ─── Check if a user is blocked (one-time check) ──────────
  Future<bool> isBlocked(String targetUserId) async {
    final blockId = '${_currentUserId}_$targetUserId';
    final doc = await _firestore.collection('blocks').doc(blockId).get();
    return doc.exists;
  }

  // ─── Real-time stream for block status ────────────────────
  Stream<bool> isBlockedStream(String targetUserId) {
    final blockId = '${_currentUserId}_$targetUserId';
    return _firestore
        .collection('blocks')
        .doc(blockId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ─── Get all user IDs blocked by current user ─────────────
  Future<List<String>> getBlockedUserIds() async {
    final snapshot = await _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: _currentUserId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['blockedId'] as String)
        .toList();
  }

  // ─── Check if another user has blocked me ─────────────────
  Future<bool> amIBlockedBy(String otherUserId) async {
    final blockId = '${otherUserId}_$_currentUserId';
    final doc = await _firestore.collection('blocks').doc(blockId).get();
    return doc.exists;
  }

  // ─── Get blocked users with their UserModel + block date ──
  Future<List<BlockedUserDetail>> getBlockedUsersWithDetails() async {
    // 1. fetch all block docs for current user
    final snapshot = await _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return [];

    // 2. for each block doc, fetch the corresponding user doc
    final List<BlockedUserDetail> result = [];

    for (final blockDoc in snapshot.docs) {
      final blockModel = BlockModel.fromMap(blockDoc.data(), blockDoc.id);

      final userDoc = await _firestore
          .collection('users')
          .doc(blockModel.blockedId)
          .get();

      if (!userDoc.exists) continue; // deleted account, skip

      final userModel = UserModel.fromMap(userDoc.data()!);

      result.add(BlockedUserDetail(block: blockModel, user: userModel));
    }

    return result;
  }
}

// ─── Simple container used only by the page ───────────────────
class BlockedUserDetail {
  final BlockModel block;
  final UserModel user;

  BlockedUserDetail({required this.block, required this.user});
}
