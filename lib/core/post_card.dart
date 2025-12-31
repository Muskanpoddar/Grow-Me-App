import 'package:flutter/material.dart';
import 'package:growme/features/auth/domain/models/post_model.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/features/auth/presentation/follow_button.dart';
import 'package:growme/features/auth/presentation/user_profile_preview_screen.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final PostRepository repo = PostRepository();

  PostCard({required this.post, required this.currentUserId, super.key});

  @override
  Widget build(BuildContext context) {
    final liked = post.likes.contains(currentUserId);
    final likeCount = post.likes.length;

    final userLabel = post.userId.length >= 6
        ? post.userId.substring(0, 6)
        : post.userId;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UserProfilePreviewScreen(userId: post.userId),
                        ),
                      );
                    },
                    child: Text(
                      'User $userLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                FollowButton(targetUserId: post.userId),
              ],
            ),

            const SizedBox(height: 10),

            // ================= CAPTION =================
            _ExpandableCaption(text: post.caption),

            const SizedBox(height: 10),

            // ================= PROOF CHIP =================
            Chip(
              avatar: Icon(
                post.imageUrl != null
                    ? Icons.check_circle
                    : Icons.hourglass_bottom,
                size: 18,
                color: Colors.white,
              ),
              backgroundColor: post.imageUrl != null
                  ? const Color(0xffD9F7D8)
                  : const Color(0xffE8E8E8),
              label: Text(
                post.imageUrl != null ? 'Proof Added' : 'No proof yet',
              ),
            ),

            const SizedBox(height: 10),

            // ================= IMAGE =================
            if (post.imageUrl != null)
              GestureDetector(
                onTap: () => _openImage(context, post.imageUrl!),
                child: Hero(
                  tag: post.imageUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      post.imageUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ================= ACTIONS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          repo.toggleLike(postId: post.id, uid: currentUserId),
                      child: Row(
                        children: [
                          Icon(
                            liked
                                ? Icons.celebration
                                : Icons.celebration_outlined,
                            color: const Color(0xff00CC66),
                          ),
                          const SizedBox(width: 6),
                          Text(_likeLabel(likeCount)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/comments',
                        arguments: {'postId': post.id},
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.comment, color: Color(0xff00CC66)),
                          SizedBox(width: 6),
                          Text('Comment'),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _share(post.id),
                  icon: const Icon(Icons.share, color: Color(0xff00CC66)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _likeLabel(int count) {
    if (count == 0) return 'Cheer';
    if (count < 5) return '$count cheered';
    return 'Many cheered';
  }

  void _share(String postId) {
    Share.share(
      '🌱 Check out this goal on GrowMe!\n\nPost ID: $postId',
      subject: 'GrowMe Goal',
    );
  }

  void _openImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullImageView(imageUrl: url)),
    );
  }
}

class _ExpandableCaption extends StatefulWidget {
  final String text;
  const _ExpandableCaption({required this.text});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Text(
        widget.text,
        maxLines: expanded ? null : 2,
        overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FullImageView extends StatelessWidget {
  final String imageUrl;
  const _FullImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(child: Image.network(imageUrl)),
        ),
      ),
    );
  }
}
