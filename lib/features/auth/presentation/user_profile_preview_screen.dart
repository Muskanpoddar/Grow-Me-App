import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/presentation/follow_button.dart';

class UserProfilePreviewScreen extends StatelessWidget {
  final String userId;

  const UserProfilePreviewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= AVATAR =================
                CircleAvatar(
                  radius: 44,
                  backgroundImage: (data['photoUrl'] ?? '').isNotEmpty
                      ? NetworkImage(data['photoUrl'])
                      : null,
                  child: (data['photoUrl'] ?? '').isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),

                const SizedBox(height: 12),

                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '@${data['username']}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // ================= FOLLOW BUTTON =================
                if (currentUid != userId) FollowButton(targetUserId: userId),

                const SizedBox(height: 20),

                // ================= INTERESTS =================
                if ((data['interests'] ?? []).isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List<String>.from(data['interests']).map((i) {
                      return Chip(
                        label: Text(i),
                        backgroundColor: Colors.green.withOpacity(0.15),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 30),

                // ================= STATS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _countTile(
                      title: 'Followers',
                      stream: FirebaseFirestore.instance
                          .collection('followers')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                    ),
                    _countTile(
                      title: 'Following',
                      stream: FirebaseFirestore.instance
                          .collection('following')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _countTile({
    required String title,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (_, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        );
      },
    );
  }
}
