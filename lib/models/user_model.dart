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

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.teachSkills,
    required this.learnSkills,
    required this.profilePicUrl,
    required this.createdAt,
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
    };
  }
}
