import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool appLockEnabled = false;
  bool hideProfile = false;
  bool loginAlerts = true;

  static const bg = Color(0xfff7faf7);
  static const green = Color(0xff00C853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            title: 'Account Security',
            children: [
              _actionTile(
                icon: Icons.lock_reset,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: _showChangePasswordInfo,
              ),
              _toggleTile(
                icon: Icons.fingerprint,
                title: 'App Lock',
                subtitle: 'Require PIN / biometrics',
                value: appLockEnabled,
                onChanged: (v) {
                  setState(() => appLockEnabled = v);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: 'Privacy',
            children: [
              _toggleTile(
                icon: Icons.visibility_off,
                title: 'Hide Profile',
                subtitle: 'Only followers can see your profile',
                value: hideProfile,
                onChanged: (v) {
                  setState(() => hideProfile = v);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: 'Alerts',
            children: [
              _toggleTile(
                icon: Icons.notifications_active,
                title: 'Login Alerts',
                subtitle: 'Get notified on new login',
                value: loginAlerts,
                onChanged: (v) {
                  setState(() => loginAlerts = v);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _dangerCard(),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: _icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      activeColor: green,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _icon(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: green.withOpacity(0.12),
      child: Icon(icon, color: green),
    );
  }

  Widget _dangerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.red,
          child: Icon(Icons.logout, color: Colors.white),
        ),
        title: const Text(
          'Clear Session',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: const Text('Remove saved login data from this device'),
        onTap: _showClearSessionInfo,
      ),
    );
  }

  // ================= DIALOGS =================

  void _showChangePasswordInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password change will be available when backend is connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearSessionInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete your account, posts, goals, and all data.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEverything();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEverything() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final db = FirebaseFirestore.instance;

    try {
      // 🔥 DELETE POSTS + COMMENTS
      final postsSnap = await db
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();

      for (final post in postsSnap.docs) {
        final comments = await post.reference.collection('comments').get();
        for (final c in comments.docs) {
          await c.reference.delete();
        }
        await post.reference.delete();
      }

      // 🔥 DELETE GOALS
      final goalsSnap = await db
          .collection('goals')
          .where('userId', isEqualTo: uid)
          .get();
      for (final g in goalsSnap.docs) {
        await g.reference.delete();
      }

      // 🔥 DELETE PROGRESS
      final progressSnap = await db
          .collection('progress_goals')
          .where('userId', isEqualTo: uid)
          .get();
      for (final p in progressSnap.docs) {
        await p.reference.delete();
      }

      // 🔥 DELETE FOLLOWERS / FOLLOWING
      final followersSnap = await db
          .collection('followers')
          .where('userId', isEqualTo: uid)
          .get();
      for (final f in followersSnap.docs) {
        await f.reference.delete();
      }

      final followingSnap = await db
          .collection('following')
          .where('userId', isEqualTo: uid)
          .get();
      for (final f in followingSnap.docs) {
        await f.reference.delete();
      }

      // 🔥 DELETE USER STATS
      await db.collection('user_stats').doc(uid).delete();

      // 🔥 DELETE USER PROFILE
      await db.collection('users').doc(uid).delete();

      // 🔥 DELETE AUTH ACCOUNT
      await user.delete();
    } catch (e) {
      debugPrint('Delete account error: $e');
    }
  }

  Future<void> deleteAccountCompletely() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      // 1️⃣ POSTS
      final posts = await firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      for (final d in posts.docs) {
        await d.reference.delete();
      }

      // 2️⃣ GOALS
      final goals = await firestore
          .collection('goals')
          .where('userId', isEqualTo: uid)
          .get();
      for (final d in goals.docs) {
        await d.reference.delete();
      }

      // 3️⃣ PROGRESS
      final progress = await firestore
          .collection('progress_goals')
          .where('userId', isEqualTo: uid)
          .get();
      for (final d in progress.docs) {
        await d.reference.delete();
      }

      // 4️⃣ FOLLOWERS (where user is being followed)
      final followers = await firestore
          .collection('followers')
          .where('userId', isEqualTo: uid)
          .get();
      for (final d in followers.docs) {
        await d.reference.delete();
      }

      // 5️⃣ FOLLOWING (where user follows others)
      final following = await firestore
          .collection('following')
          .where('userId', isEqualTo: uid)
          .get();
      for (final d in following.docs) {
        await d.reference.delete();
      }

      // 6️⃣ USER STATS
      await firestore.collection('user_stats').doc(uid).delete();

      // 7️⃣ USER PROFILE
      await firestore.collection('users').doc(uid).delete();

      // 8️⃣ FINALLY DELETE AUTH ACCOUNT
      await user.delete();
    } catch (e) {
      debugPrint('Delete account error: $e');
      rethrow;
    }
  }
}
