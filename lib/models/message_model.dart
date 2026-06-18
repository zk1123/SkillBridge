import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final Timestamp sentAt;
  final String? type; // 'text', 'image', 'file'
  final String? mediaUrl; // For images/files
  final String? fileName; // For files
  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.type,
    this.mediaUrl,
    this.fileName,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'],
      text: map['text'],
      sentAt: map['sentAt'] is Timestamp
          ? map['sentAt'] as Timestamp
          : (map['timestamp'] is Timestamp
                ? map['timestamp'] as Timestamp
                : Timestamp.now()),
      type: map['type'] == 'pdf' ? 'file' : (map['type']?.toString() ?? 'text'),
      mediaUrl: map['mediaUrl'],
      fileName: map['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': sentAt,
      'type': type,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
    };
  }
}
