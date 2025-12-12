import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> createPost({
    required String title,
    required String imageUrl,
    required bool proofAdded,
  }) async {
    final uid = _auth.currentUser!.uid;

    final userDoc = await _firestore.collection("users").doc(uid).get();

    final username = userDoc["username"];
    final userAvatar = userDoc["photoUrl"];

    final newPost = {
      "uid": uid,
      "username": username,
      "userAvatar": userAvatar,
      "title": title,
      "imageUrl": imageUrl,
      "proofAdded": proofAdded,
      "cheersCount": 0,
      "commentsCount": 0,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _firestore.collection("posts").add(newPost);
  }

  Future<void> addCheers(String postId) async {
    await _firestore.collection("posts").doc(postId).update({
      "cheersCount": FieldValue.increment(1),
    });
  }
}
