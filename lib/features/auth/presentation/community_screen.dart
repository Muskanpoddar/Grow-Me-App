import 'package:flutter/material.dart';
import 'package:growme/features/auth/presentation/community_header.dart';
import 'package:growme/features/auth/presentation/followers_list.dart';
import 'package:growme/features/auth/presentation/following_list.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool showFollowing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        title: const Text('Community'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommunityHeader(),

          // FOLLOW / FOLLOWERS SWITCH
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
                  _tab('Following', showFollowing, () {
                    setState(() => showFollowing = true);
                  }),
                  _tab('Followers', !showFollowing, () {
                    setState(() => showFollowing = false);
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: showFollowing
                ? const FollowingList()
                : const FollowersList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/userSearch');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
