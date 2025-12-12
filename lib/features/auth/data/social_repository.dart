import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // FOLLOW
  Future<void> followUser(String targetUid) async {
    await _firestore
        .collection("followers")
        .doc(targetUid)
        .collection("userFollowers")
        .doc(currentUid)
        .set({});

    await _firestore
        .collection("following")
        .doc(currentUid)
        .collection("userFollowing")
        .doc(targetUid)
        .set({});
  }

  // UNFOLLOW
  Future<void> unfollowUser(String targetUid) async {
    await _firestore
        .collection("followers")
        .doc(targetUid)
        .collection("userFollowers")
        .doc(currentUid)
        .delete();

    await _firestore
        .collection("following")
        .doc(currentUid)
        .collection("userFollowing")
        .doc(targetUid)
        .delete();
  }

  // CHECK IF FOLLOWING (REAL TIME)
  Stream<bool> isFollowing(String targetUid) {
    return _firestore
        .collection("followers")
        .doc(targetUid)
        .collection("userFollowers")
        .doc(currentUid)
        .snapshots()
        .map((snap) => snap.exists);
  }
}
