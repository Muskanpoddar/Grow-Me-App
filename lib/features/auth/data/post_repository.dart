import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/cloudinary_service.dart';
import '../domain/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference get postsRef => _firestore.collection('posts');

  // 🔹 HOME FEED
  Stream<List<PostModel>> streamHomeFeed() {
    return postsRef
        .where('userId', isGreaterThan: '') // 👈 forces index match
        .orderBy('userId')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PostModel.fromDoc(d)).toList());
  }

  // 🔹 CREATE POST
  Future<void> createPost({required String caption, File? imageFile}) async {
    final uid = _auth.currentUser!.uid;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _cloudinary.uploadImage(imageFile);
    }

    final userSnap = await _firestore.collection('users').doc(uid).get();
    final user = userSnap.data() ?? {};

    await postsRef.add({
      'userId': uid,
      'name': user['name'] ?? '',
      'username': user['username'] ?? '',
      'photoUrl': user['photoUrl'],
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': [],
      'hideLikes': false,
      'hideComments': false,
      'createdAt': Timestamp.now(),
    });
  }

  // 🔹 DELETE POST + COMMENTS
  Future<void> deletePost(String postId) async {
    final postRef = postsRef.doc(postId);
    final commentsSnap = await postRef.collection('comments').get();

    final batch = _firestore.batch();

    for (final doc in commentsSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(postRef);
    await batch.commit();
  }

  // 🔹 LIKE / UNLIKE POST
  Future<void> toggleLike({required String postId, required String uid}) async {
    final ref = postsRef.doc(postId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      likes.contains(uid) ? likes.remove(uid) : likes.add(uid);
      tx.update(ref, {'likes': likes});
    });
  }

  // 🔹 TOGGLE VISIBILITY
  Future<void> toggleVisibility({
    required String postId,
    required String field,
    required bool value,
  }) async {
    if (field != 'hideLikes' && field != 'hideComments') return;
    await postsRef.doc(postId).update({field: value});
  }

  // 🔹 ADD COMMENT
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = _auth.currentUser!.uid;

    final userSnap = await _firestore.collection('users').doc(uid).get();
    final user = userSnap.data() ?? {};

    await postsRef.doc(postId).collection('comments').add({
      'userId': uid,
      'username': user['username'] ?? '',
      'name': user['name'] ?? '',
      'photoUrl': user['photoUrl'],
      'text': text,
      'likes': [],
      'createdAt': Timestamp.now(),
    });
  }

  // 🔹 DELETE COMMENT
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await postsRef.doc(postId).collection('comments').doc(commentId).delete();
  }

  // 🔹 LIKE / UNLIKE COMMENT
  Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
    required String uid,
  }) async {
    final ref = postsRef.doc(postId).collection('comments').doc(commentId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      likes.contains(uid) ? likes.remove(uid) : likes.add(uid);
      tx.update(ref, {'likes': likes});
    });
  }

  // 🔹 STREAM COMMENTS
  Stream<QuerySnapshot> streamComments(String postId) {
    return postsRef
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
