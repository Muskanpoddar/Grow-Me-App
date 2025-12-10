class AppUser {
  final String uid;
  final String? email;
  final String name;
  final String username;
  final String? photoUrl;
  final List<String> interests;

  AppUser({
    required this.uid,
    this.email,
    required this.name,
    required this.username,
    this.photoUrl,
    required this.interests,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'username': username,
      'photoUrl': photoUrl,
      'interests': interests,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
