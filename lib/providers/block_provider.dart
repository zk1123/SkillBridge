import 'package:flutter/material.dart';
import '../services/block_service.dart';

class BlockProvider extends ChangeNotifier {
  final BlockService _blockService = BlockService();

  Set<String> _blockedIds = {};
  bool _isLoading = false;
  String? _error;

  Set<String> get blockedIds => _blockedIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Call this right after login ──────────────────────────
  Future<void> loadBlockedUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ids = await _blockService.getBlockedUserIds();
      _blockedIds = ids.toSet();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Block a user ─────────────────────────────────────────
  Future<void> blockUser(String userId) async {
    try {
      await _blockService.blockUser(userId);
      _blockedIds = {..._blockedIds, userId};
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _blockService.unblockUser(userId);
      _blockedIds = _blockedIds.where((id) => id != userId).toSet();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── Check from cache (no Firestore call) ─────────────────
  bool isUserBlocked(String userId) => _blockedIds.contains(userId);

  // ─── Clear on logout ──────────────────────────────────────
  void clear() {
    _blockedIds = {};
    _error = null;
    notifyListeners();
  }
}
