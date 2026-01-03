import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/data/post_repository.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _repo = PostRepository();
  final _controller = TextEditingController();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  String? postId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postId =
        (ModalRoute.of(context)?.settings.arguments as Map?)?['postId'];
  }

  Future<void> _addComment() async {
    if (postId == null || _controller.text.trim().isEmpty) return;
    await _repo.addComment(postId: postId!, text: _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (postId == null) {
      return const Scaffold(body: Center(child: Text('No post')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: const Color(0xff00CC66),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _repo.streamComments(postId!),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final d = doc.data() as Map<String, dynamic>;
                    final liked = (d['likes'] ?? []).contains(_uid);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: d['photoUrl'] != null
                            ? NetworkImage(d['photoUrl'])
                            : null,
                        child: d['photoUrl'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            d['username'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(d['createdAt']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MentionText(d['text']),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _repo.toggleCommentLike(
                                  postId: postId!,
                                  commentId: doc.id,
                                  uid: _uid,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(d['likes'] ?? []).length}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (d['userId'] == _uid)
                                GestureDetector(
                                  onTap: () => _repo.deleteComment(
                                    postId: postId!,
                                    commentId: doc.id,
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xff00CC66)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
class _MentionText extends StatelessWidget {
  final String text;
  const _MentionText(this.text);

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');

    return Wrap(
      children: words.map((w) {
        if (w.startsWith('@')) {
          return Text(
            '$w ',
            style: const TextStyle(
              color: Color(0xff00CC66),
              fontWeight: FontWeight.bold,
            ),
          );
        }
        return Text('$w ');
      }).toList(),
    );
  }
}
