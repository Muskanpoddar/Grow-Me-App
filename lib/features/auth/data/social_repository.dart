import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // FOLLOW
  Future<void> followUser(String targetUid) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);

    final followersRef = _firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(currentUid);

    batch.set(followingRef, {
      'userId': targetUid,
      'createdAt': Timestamp.now(),
    });

    batch.set(followersRef, {
      'userId': currentUid,
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
  }

  // UNFOLLOW
  Future<void> unfollowUser(String targetUid) async {
    final batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid),
    );

    batch.delete(
      _firestore
          .collection('users')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid),
    );

    await batch.commit();
  }

  // CHECK FOLLOW STATE (REAL TIME)
  Stream<bool> isFollowing(String targetUid) {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
