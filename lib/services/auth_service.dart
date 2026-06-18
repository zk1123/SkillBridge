import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // sign up
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: result.user!.uid,
      name: name,
      email: email,
      bio: '',
      teachSkills: [],
      learnSkills: [],
      profilePicUrl: '',
      createdAt: Timestamp.now(),
      averageRating: 0.0,
      reviewCount: 0,
    );

    await _db.collection('users').doc(user.uid).set(user.toMap());

    return user;
  }

  // sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db.collection('users').doc(result.user!.uid).get();

    return UserModel.fromMap(doc.data()!);
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
