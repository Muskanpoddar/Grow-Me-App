import 'package:flutter/material.dart';
import 'package:growme/core/post_card.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:growme/features/auth/domain/models/post_model.dart';
import 'package:growme/features/auth/presentation/community_screen.dart';
import 'package:growme/features/auth/presentation/create_post_screen.dart';
import 'package:growme/features/auth/presentation/goal_screen.dart';
import 'package:growme/features/auth/presentation/progress_screen.dart';
import 'package:growme/features/auth/presentation/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const HomeScreen({super.key, required this.userId, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<Widget> get _pages => [
    _HomeFeed(currentUserId: widget.userId),
    const GoalsScreen(),
    const ProgressScreen(),
    const CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xff00CC66),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
              child: const Icon(Icons.add, color: Colors.black),
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
  final String currentUserId;
  final PostRepository repo = PostRepository();

  _HomeFeed({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: repo.streamHomeFeed(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snap.data ?? [];
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts yet.',
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
                      currentUserId: currentUserId,
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
