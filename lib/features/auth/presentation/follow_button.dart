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

    final followingQuery = FirebaseFirestore.instance
        .collection('following')
        .where('userId', isEqualTo: currentUid)
        .where('followingId', isEqualTo: targetUserId);

    return StreamBuilder<QuerySnapshot>(
      stream: followingQuery.snapshots(),
      builder: (context, snap) {
        final isFollowing = snap.data?.docs.isNotEmpty == true;

        return GestureDetector(
          onTap: () async {
            final batch = FirebaseFirestore.instance.batch();

            if (isFollowing) {
              for (final doc in snap.data!.docs) {
                batch.delete(doc.reference);
              }

              final followersSnap = await FirebaseFirestore.instance
                  .collection('followers')
                  .where('userId', isEqualTo: targetUserId)
                  .where('followerId', isEqualTo: currentUid)
                  .get();

              for (final doc in followersSnap.docs) {
                batch.delete(doc.reference);
              }
            } else {
              batch.set(
                FirebaseFirestore.instance.collection('following').doc(),
                {
                  'userId': currentUid,
                  'followingId': targetUserId,
                  'createdAt': FieldValue.serverTimestamp(),
                },
              );

              batch.set(
                FirebaseFirestore.instance.collection('followers').doc(),
                {
                  'userId': targetUserId,
                  'followerId': currentUid,
                  'createdAt': FieldValue.serverTimestamp(),
                },
              );
            }

            await batch.commit();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isFollowing
                  ? Colors.grey.shade300
                  : const Color(0xff00CC66),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
