import 'package:flutter/material.dart';
import 'package:growme/core/post_card.dart';
import 'package:growme/features/auth/domain/models/post_model.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/features/auth/presentation/create_post_screen.dart';
import 'package:growme/features/auth/presentation/progress_screen.dart';
import 'package:growme/features/auth/presentation/setting_screen.dart';
import 'package:growme/features/auth/presentation/updated_goal_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;
  const HomeScreen({super.key, required this.userId, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = PostRepository();

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // ✅ SET FROM PARAM
  }

  // pages for bottom nav (Goals and others are placeholders here)
  List<Widget> get _pages => [
    _HomeFeed(userId: widget.userId),
    const _GoalsScreen(),
    const ProgressScreen(),
    const _CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xff00CC66),
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
            )
          : null,

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
  final String userId;

  const _HomeFeed({required this.userId});

  @override
  Widget build(BuildContext context) {
    final repo = PostRepository();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: repo.streamPosts(userId), // ✅ FIXED
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
                    return PostCard(
                      post: posts[index],
                      currentUserId: userId, // ✅ use passed userId
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

class _CommunityScreen extends StatelessWidget {
  const _CommunityScreen();
  @override
  Widget build(BuildContext c) =>
      const Center(child: Text('Community screen (placeholder)'));
}
