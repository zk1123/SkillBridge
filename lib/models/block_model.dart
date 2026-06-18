import 'package:cloud_firestore/cloud_firestore.dart';

class BlockModel {
  final String blockId;
  final String blockerId;
  final String blockedId;
  final Timestamp createdAt;

  BlockModel({
    required this.blockId,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map, String id) {
    return BlockModel(
      blockId: id,
      blockerId: map['blockerId'] as String? ?? '',
      blockedId: map['blockedId'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blockerId': blockerId,
      'blockedId': blockedId,
      'createdAt': createdAt,
    };
  }
}
