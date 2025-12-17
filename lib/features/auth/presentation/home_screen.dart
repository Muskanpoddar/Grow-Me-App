import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growme/core/post_card.dart';
import 'package:growme/core/post_model.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/features/auth/presentation/create_post_screen.dart';
import 'package:growme/features/auth/presentation/setting_screen.dart';
import 'package:growme/features/auth/presentation/updated_goal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = PostRepository();

  int _currentIndex = 0;

  // pages for bottom nav (Goals and others are placeholders here)
  final List<Widget> _pages = [
    const _HomeFeed(), // index 0: home feed
    const _GoalsScreen(), // index 1: goals
    const _ProgressScreen(), // index 2: progress
    const _CommunityScreen(), // index 3: community
    const SettingsScreen(), // index 4: settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00CC66),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          // push full screen create post (A2: hide bottom nav while creating)
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff00CC66),
        unselectedItemColor: Colors.black54,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

  @override
  Widget build(BuildContext context) {
    final repo = PostRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: repo.streamPosts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snap.data ?? [];
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts yet.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index], currentUserId: uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: const [
        SizedBox(width: 15),
        Icon(Icons.directions_run_rounded, size: 30, color: Color(0xff00CC66)),
        SizedBox(width: 10),
        Text(
          "Home Feed",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Simple Goals placeholder - tapping the top button navigates to the UpdateGoal screen
class _GoalsScreen extends StatelessWidget {
  const _GoalsScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: const [
              SizedBox(width: 15),
              Text(
                "Goals",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff00CC66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Update Today\'s Goal',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal Progress and Community screens (replace with full UIs later)
class _ProgressScreen extends StatelessWidget {
  const _ProgressScreen();
  @override
  Widget build(BuildContext c) =>
      const Center(child: Text('Progress screen (placeholder)'));
}

class _CommunityScreen extends StatelessWidget {
  const _CommunityScreen();
  @override
  Widget build(BuildContext c) =>
      const Center(child: Text('Community screen (placeholder)'));
}
