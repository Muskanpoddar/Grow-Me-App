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
        title: const Text('Clear Session'),
        content: const Text(
          'This will clear local session data from the device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Session cleared')));
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
