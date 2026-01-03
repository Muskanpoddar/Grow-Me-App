import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const bg = Color(0xfff7faf7);
  static const green = Color(0xff00C853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _appHeader(),
          const SizedBox(height: 16),
          _infoTile(
            title: 'What is GrowMe?',
            value: 'A daily goal and habit tracking app',
            icon: Icons.flag,
          ),
          _infoTile(
            title: 'Purpose',
            value: 'Build consistency and personal growth',
            icon: Icons.trending_up,
          ),
          _infoTile(
            title: 'Target Users',
            value: 'Students & self-improvement focused users',
            icon: Icons.people,
          ),
          _infoTile(
            title: 'Platform',
            value: 'Mobile Application',
            icon: Icons.phone_android,
          ),
          _infoTile(
            title: 'Technology',
            value: 'Built using Flutter',
            icon: Icons.code,
          ),
          _infoTile(title: 'Version', value: '1.0.0', icon: Icons.info_outline),
          const SizedBox(height: 24),
          _footer(),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _appHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.eco, size: 48, color: green),
          SizedBox(height: 12),
          Text(
            'GrowMe',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Grow daily. Grow better.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: green.withOpacity(0.15),
            child: Icon(icon, color: green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Center(
      child: Column(
        children: const [
          Text(
            'Made with ❤️ for personal growth',
            style: TextStyle(color: Colors.black45),
          ),
          SizedBox(height: 6),
          Text(
            '© 2026 GrowMe',
            style: TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
