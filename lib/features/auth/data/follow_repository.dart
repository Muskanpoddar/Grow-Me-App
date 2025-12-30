import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ================= FOLLOW =================
  Future<void> follow(String targetUserId) async {
    final batch = _firestore.batch();
    final now = Timestamp.now();

    final followingRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('following')
        .doc(targetUserId);

    final followersRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(_uid);

    batch.set(followingRef, {'userId': targetUserId, 'createdAt': now});

    batch.set(followersRef, {'userId': _uid, 'createdAt': now});

    await batch.commit();
  }

  // ================= UNFOLLOW =================
  Future<void> unfollow(String targetUserId) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('following')
        .doc(targetUserId);

    final followersRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(_uid);

    batch.delete(followingRef);
    batch.delete(followersRef);

    await batch.commit();
  }

  // ================= CHECK FOLLOWING =================
  Stream<bool> isFollowing(String targetUserId) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('following')
        .doc(targetUserId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
