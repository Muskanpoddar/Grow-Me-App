import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/data/auth_repository.dart';
import 'package:growme/features/auth/presentation/notification_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';

import 'security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const bg = Color(0xfff7faf7);
  static const green = Color(0xff00C853);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  static Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: _card(
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: green.withOpacity(0.15),
                child: Icon(icon, color: green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepo = AuthRepository();

    return Scaffold(
      backgroundColor: SettingsScreen.bg,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // USER CARD
          SettingsScreen._card(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: SettingsScreen.green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SettingsScreen._sectionTitle('PREFERENCES'),

          SettingsScreen._item(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () =>
                SettingsScreen._open(context, const NotificationScreen()),
          ),
          SettingsScreen._item(
            context,
            icon: Icons.security,
            title: 'Security',
            onTap: () => SettingsScreen._open(context, const SecurityScreen()),
          ),

          const SizedBox(height: 24),
          SettingsScreen._sectionTitle('LEGAL'),

          SettingsScreen._item(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () =>
                SettingsScreen._open(context, const PrivacyPolicyScreen()),
          ),
          SettingsScreen._item(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => SettingsScreen._open(context, const AboutScreen()),
          ),

          const SizedBox(height: 30),

          // LOGOUT
          GestureDetector(
            onTap: () async {
              await authRepo.logout();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
