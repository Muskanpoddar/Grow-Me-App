import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/data/post_repository.dart';


class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});
  @override State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _repo = PostRepository();
  final _controller = TextEditingController();
  String? postId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    postId = args != null ? args['postId'] as String : null;
  }

  Future _addComment() async {
    if (postId == null || _controller.text.trim().isEmpty) return;
    await _repo.addComment(postId: postId!, text: _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (postId == null) return Scaffold(body: Center(child: Text('No post selected')));
    return Scaffold(
      appBar: AppBar(title: const Text('Comments'), backgroundColor: const Color(0xff00CC66), foregroundColor: Colors.black),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _repo.streamComments(postId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!;
              if (docs.isEmpty) return const Center(child: Text('No comments yet'));
              return ListView.builder(
                reverse: true,
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(d['userId']!.toString().substring(0, d['userId']?.toString().length ?? 0)),
                    subtitle: Text(d['text'] ?? ''),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Write a comment...'))),
            IconButton(onPressed: _addComment, icon: const Icon(Icons.send, color: Color(0xff00CC66)))
          ]),
        )
      ]),
    );
  }
}
