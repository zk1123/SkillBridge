import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final List<String> teachSkills;
  final List<String> learnSkills;
  final String profilePicUrl;
  final Timestamp createdAt;
  final double averageRating;
  final int reviewCount;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.teachSkills,
    required this.learnSkills,
    required this.profilePicUrl,
    required this.createdAt,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      bio: map['bio'] ?? '',
      teachSkills: List<String>.from(map['teachSkills'] ?? []),
      learnSkills: List<String>.from(map['learnSkills'] ?? []),
      profilePicUrl: map['profilePicUrl'] ?? '',
      createdAt: map['createdAt'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'teachSkills': teachSkills,
      'learnSkills': learnSkills,
      'profilePicUrl': profilePicUrl,
      'createdAt': createdAt,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }
}
