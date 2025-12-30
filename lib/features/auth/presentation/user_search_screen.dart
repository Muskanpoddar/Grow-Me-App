import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/presentation/user_profile_preview_screen.dart';
import 'package:rxdart/rxdart.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  Stream<List<DocumentSnapshot>>? _searchStream;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final q = value.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => _searchStream = null);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      final usersRef = FirebaseFirestore.instance.collection('users');

      final usernameQuery = usersRef
          .where('username_lower', isGreaterThanOrEqualTo: q)
          .where('username_lower', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(10)
          .snapshots();

      final nameQuery = usersRef
          .where('name_lower', isGreaterThanOrEqualTo: q)
          .where('name_lower', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(10)
          .snapshots();

      setState(() {
        _searchStream = CombineLatestStream.combine2(usernameQuery, nameQuery, (
          QuerySnapshot a,
          QuerySnapshot b,
        ) {
          final map = <String, DocumentSnapshot>{};

          for (final d in a.docs) {
            map[d.id] = d;
          }
          for (final d in b.docs) {
            map[d.id] = d;
          }

          return map.values.toList();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        title: const Text('Find Friends'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or username',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _searchStream == null
                ? const Center(
                    child: Text(
                      'Search users by name or username',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : StreamBuilder<List<DocumentSnapshot>>(
                    stream: _searchStream,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snap.hasData || snap.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final docs = snap.data!
                          .where((d) => d.id != currentUid)
                          .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    (data['photoUrl'] ?? '').isNotEmpty
                                    ? NetworkImage(data['photoUrl'])
                                    : null,
                                child: (data['photoUrl'] ?? '').isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('@${data['username']}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfilePreviewScreen(
                                      userId: docs[i].id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
