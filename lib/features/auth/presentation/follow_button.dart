import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final String targetUserId;
  const FollowButton({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    if (currentUid == targetUserId) return const SizedBox();

    final followingDoc = FirebaseFirestore.instance
        .collection('following')
        .doc('${currentUid}_$targetUserId');

    return StreamBuilder<DocumentSnapshot>(
      stream: followingDoc.snapshots(),
      builder: (context, snap) {
        final isFollowing =
            snap.connectionState == ConnectionState.active &&
            snap.data?.exists == true;

        return GestureDetector(
          onTap: () async {
            final batch = FirebaseFirestore.instance.batch();

            final followerDoc = FirebaseFirestore.instance
                .collection('followers')
                .doc('${targetUserId}_$currentUid');

            if (isFollowing) {
              batch.delete(followingDoc);
              batch.delete(followerDoc);
            } else {
              batch.set(followingDoc, {
                'userId': currentUid,
                'followingId': targetUserId,
                'createdAt': FieldValue.serverTimestamp(),
              });

              batch.set(followerDoc, {
                'userId': targetUserId,
                'followerId': currentUid,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }

            await batch.commit();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey.shade300 : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
