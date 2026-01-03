import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/core/post_card.dart';
import 'package:growme/features/auth/domain/models/post_model.dart';

class MyPosts extends StatelessWidget {
  MyPosts({super.key});

  final _repo = PostRepository();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late final String _uid = uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _repo.postsRef
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(PostModel.fromDoc).toList()),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = snap.data ?? [];

        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'You haven’t posted anything yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index], currentUserId: _uid);
          },
        );
      },
    );
  }
}
