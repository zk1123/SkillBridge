import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String reviewerId;
  final String reviewedId;
  final String matchId;
  final int rating;
  final List<String> tags;
  final String text;
  final String? reply;
  final Timestamp createdAt;

  ReviewModel({
    required this.reviewId,
    required this.reviewerId,
    required this.reviewedId,
    required this.matchId,
    required this.rating,
    required this.tags,
    required this.text,
    this.reply,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      reviewId: id,
      reviewerId: map['reviewerId'],
      reviewedId: map['reviewedId'],
      matchId: map['matchId'],
      rating: map['rating'],
      tags: List<String>.from(map['tags'] ?? []),
      text: map['text'] ?? '',
      reply: map['reply'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewedId': reviewedId,
      'matchId': matchId,
      'rating': rating,
      'tags': tags,
      'text': text,
      'reply': reply,
      'createdAt': createdAt,
    };
  }
}
