import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growme/features/auth/presentation/user_profile_preview_screen.dart';

class FollowersList extends StatelessWidget {
  const FollowersList({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        title: const Text('Followers'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('followers')
              .where('userId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No followers yet',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            final docs = snap.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (c, i) {
                final followerId = docs[i]['followerId'];
                return _UserTile(userId: followerId);
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String userId;
  const _UserTile({required this.userId});

  @override
  Widget build(BuildContext context) {
    String _initialFromName(String? name) {
      final n = name?.trim() ?? '';
      return n.isNotEmpty ? n[0].toUpperCase() : 'U';
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final photoUrl = data['photoUrl'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePreviewScreen(userId: userId),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage:
                  photoUrl != null && photoUrl.toString().isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.toString().isEmpty
                  ? Text(
                      _initialFromName(data['name']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),

            title: Text(
              data['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '@${data['username'] ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
