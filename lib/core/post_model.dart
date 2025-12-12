import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String caption;
  final String? imageUrl;
  final List<String> likes;
  final Timestamp createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.caption,
    this.imageUrl,
    required this.likes,
    required this.createdAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'caption': caption,
    'imageUrl': imageUrl,
    'likes': likes,
    'createdAt': createdAt,
  };
}
