import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final Timestamp sentAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'],
      text: map['text'],
      sentAt: map['sentAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'text': text, 'sentAt': sentAt};
  }
}
