import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/presentation/follow_button.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/core/post_card.dart';
import 'package:growme/features/auth/domain/models/post_model.dart';

class UserProfilePreviewScreen extends StatelessWidget {
  final String userId;

  const UserProfilePreviewScreen({super.key, required this.userId});

  static const bg = Color(0xfff7faf7);
  static const green = Color(0xff00C853);

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bg,
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
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final bio = (data['bio'] ?? '').toString().trim();
          final interests = List<String>.from(data['interests'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= PROFILE CARD =================
                _profileCard(data, currentUid),

                const SizedBox(height: 18),

                // ================= BIO =================
                if (bio.isNotEmpty) _bioSection(bio),

                if (bio.isNotEmpty) const SizedBox(height: 18),

                // ================= INTERESTS =================
                if (interests.isNotEmpty) _interestsSection(interests),

                if (interests.isNotEmpty) const SizedBox(height: 24),

                // ================= POSTS =================
                const Text(
                  'Posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _UserPosts(userId: userId),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= PROFILE CARD =================

  Widget _profileCard(Map<String, dynamic> data, String currentUid) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundImage: (data['photoUrl'] ?? '').toString().isNotEmpty
                  ? NetworkImage(data['photoUrl'])
                  : null,
              child: (data['photoUrl'] ?? '').toString().isEmpty
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),

            const SizedBox(height: 14),

            Text(
              data['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              '@${data['username'] ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            if (currentUid != userId) FollowButton(targetUserId: userId),

            const SizedBox(height: 20),
            const Divider(),

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
      ),
    );
  }

  // ================= BIO =================

  Widget _bioSection(String bio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(bio, style: const TextStyle(color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  // ================= INTERESTS (GOAL STYLE) =================

  Widget _interestsSection(List<String> interests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: interests.map((i) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: green.withOpacity(0.4)),
                ),
                child: Text(
                  i,
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ================= COUNT TILE =================

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

// ================= USER POSTS =================

class _UserPosts extends StatelessWidget {
  final String userId;
  final repo = PostRepository();

  _UserPosts({required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<PostModel>>(
      stream: repo.postsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => PostModel.fromDoc(d)).toList()),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = snap.data ?? [];

        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('No posts yet', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index], currentUserId: currentUid);
          },
        );
      },
    );
  }
}
