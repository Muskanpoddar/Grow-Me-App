import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/core/post_model.dart';

import '../../../core/services/cloudinary_service.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference postsRef = FirebaseFirestore.instance.collection(
    'posts',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  Stream<List<PostModel>> streamPosts() {
    return postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PostModel.fromDoc(d)).toList());
  }

  Future<void> createPost({required String caption, File? imageFile}) async {
    final uid = _auth.currentUser!.uid;
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _cloudinary.uploadImage(imageFile);
    }

    final doc = postsRef.doc();
    await doc.set({
      'userId': uid,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': [],
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> toggleLike({required String postId, required String uid}) async {
    final docRef = postsRef.doc(postId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data()! as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      tx.update(docRef, {'likes': likes});
    });
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = _auth.currentUser!.uid;
    final commentsRef = postsRef.doc(postId).collection('comments');
    await commentsRef.add({
      'userId': uid,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<QueryDocumentSnapshot>> streamComments(String postId) {
    return postsRef
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }
}
