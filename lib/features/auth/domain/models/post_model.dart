import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String name;
  final String username;
  final String? photoUrl;
  final String caption;
  final String? imageUrl;
  final List<String> likes;
  final bool hideLikes;
  final bool hideComments;

  PostModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    required this.caption,
    required this.likes,
    this.photoUrl,
    this.imageUrl,
    this.hideLikes = false,
    this.hideComments = false,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      userId: data['userId'],
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'],
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      hideLikes: data['hideLikes'] ?? false,
      hideComments: data['hideComments'] ?? false,
    );
  }
}
