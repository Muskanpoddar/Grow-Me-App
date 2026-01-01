import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String usernameLower;
  final String? photoUrl;
  final List<String> interests;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.usernameLower,
    required this.interests,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'name_lower': name.toLowerCase(),
      'email': email,
      'username': username,
      'username_lower': usernameLower,
      'photoUrl': photoUrl,
      'interests': interests,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      usernameLower: map['username_lower'] ?? '',
      photoUrl: map['photoUrl'],
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
