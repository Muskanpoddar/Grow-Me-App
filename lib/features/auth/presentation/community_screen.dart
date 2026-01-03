import 'package:flutter/material.dart';
import 'package:growme/features/auth/presentation/my_posts.dart';

import 'community_header.dart';
import 'followers_list.dart';
import 'following_list.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static const green = Color(0xff00C853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.people_alt_rounded, color: green, size: 26),
            SizedBox(width: 8),
            Text(
              'Community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // PROFILE HEADER
          const CommunityHeader(),

          const SizedBox(height: 8),

          // FOLLOW / FOLLOWING BUTTONS (NAVIGATION ONLY)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _navButton(
                    context,
                    label: 'Following',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowingList(),
                        ),
                      );
                    },
                  ),
                  _navButton(
                    context,
                    label: 'Followers',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowersList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🔥 ALWAYS SHOW YOUR POSTS
          Expanded(child: MyPosts()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        onPressed: () {
          Navigator.pushNamed(context, '/userSearch');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  static Widget _navButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
