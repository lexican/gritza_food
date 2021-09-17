import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  factory User.fromSnapshot(DocumentSnapshot doc) {
    Map getDocs = doc.data();
    return User(
      id: getDocs['id'],
      email: getDocs['email'],
      username: getDocs['username'],
      photoUrl: getDocs['photoUrl'],
      displayName: getDocs['displayName'],
      bio: getDocs['bio'],
    );
  }
}
