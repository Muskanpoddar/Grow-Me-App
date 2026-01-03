import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const bg = Color(0xfff7faf7);
  static const green = Color(0xff00C853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 16),
          _policyTile(
            title: 'Information We Collect',
            points: [
              'Basic profile information',
              'Goals and activity data',
              'App usage information',
            ],
          ),
          _policyTile(
            title: 'How We Use Your Data',
            points: [
              'To personalize your experience',
              'To track goals and progress',
              'To improve app performance',
            ],
          ),
          _policyTile(
            title: 'Data Sharing',
            points: [
              'We do not sell your data',
              'Your data is not shared with third parties',
            ],
          ),
          _policyTile(
            title: 'Data Security',
            points: [
              'We use secure storage practices',
              'Only you control your data',
            ],
          ),
          _policyTile(
            title: 'Your Control',
            points: [
              'Edit your profile anytime',
              'You may delete your account',
            ],
          ),
          const SizedBox(height: 24),
          _footer(),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xffE6F6EC),
            child: Icon(Icons.privacy_tip, color: green),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Your privacy matters. We keep your data safe and transparent.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _policyTile({required String title, required List<String> points}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
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
            'Last updated: January 2026',
            style: TextStyle(color: Colors.black45),
          ),
          SizedBox(height: 6),
          Text(
            'GrowMe respects your privacy',
            style: TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
