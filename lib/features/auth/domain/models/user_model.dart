class AppUser {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String? photoUrl;
  final List<String> interests;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.interests,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'interests': interests,
      'photoUrl': photoUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      username: map['username'],
      interests: List<String>.from(map['interests']),
      photoUrl: map['photoUrl'],
    );
  }
}
