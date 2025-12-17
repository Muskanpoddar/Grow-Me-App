import 'package:flutter/material.dart';
import 'package:growme/core/post_model.dart';
import 'package:growme/features/auth/data/post_repository.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final PostRepository repo = PostRepository();

  PostCard({required this.post, required this.currentUserId, super.key});

  @override
  Widget build(BuildContext context) {
    final liked = post.likes.contains(currentUserId);
    final likeCount = post.likes.length;

    // safe user label - if too short just show entire id or first 6
    final userLabel = post.userId.length >= 6 ? post.userId.substring(0, 6) : post.userId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Expanded(child: Text('User $userLabel', style: const TextStyle(fontWeight: FontWeight.bold))),
            _FollowButton(targetUserId: post.userId),
          ]),

          const SizedBox(height: 12),
          Text(post.caption, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(children: [
            Chip(
              avatar: Icon(
                post.imageUrl != null ? Icons.check_circle : Icons.hourglass_bottom,
                size: 18,
                color: Colors.white,
              ),
              backgroundColor: post.imageUrl != null ? const Color(0xffD9F7D8) : const Color(0xffE8E8E8),
              label: Text(post.imageUrl != null ? 'Proof Added' : 'No proof yet'),
            )
          ]),

          const SizedBox(height: 12),
          if (post.imageUrl != null)
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(post.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)),

          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              GestureDetector(
                onTap: () => repo.toggleLike(postId: post.id, uid: currentUserId),
                child: Row(children: [
                  Icon(liked ? Icons.celebration : Icons.celebration_outlined, color: const Color(0xff00CC66)),
                  const SizedBox(width: 6),
                  Text(_likeLabel(likeCount)),
                ]),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/comments', arguments: {'postId': post.id}),
                child: Row(children: const [Icon(Icons.comment, color: Color(0xff00CC66)), SizedBox(width: 6), Text('Comment')]),
              ),
            ]),

            Row(children: [
              IconButton(onPressed: () => _share(post.id), icon: const Icon(Icons.share, color: Color(0xff00CC66)))
            ])
          ])
        ]),
      ),
    );
  }

  String _likeLabel(int count) {
    if (count == 0) return 'Cheer';
    if (count < 5) return '$count cheered';
    return 'Many cheered';
  }

  void _share(String postId) {
    // implement share with share_plus if you want
  }
}

class _FollowButton extends StatelessWidget {
  final String targetUserId;
  const _FollowButton({required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    // placeholder style — replace with real follow logic later
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xff00CC66), borderRadius: BorderRadius.circular(20)),
      child: const Text('Follow', style: TextStyle(color: Colors.white)),
    );
  }
}
