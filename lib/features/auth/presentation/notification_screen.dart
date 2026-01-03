import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      title: 'Complete today’s goal',
      message: 'Don’t forget to complete your daily goal 🎯',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AppNotification(
      title: 'You’re on a streak!',
      message: '🔥 3 days streak — keep going!',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      title: 'New follower',
      message: 'Someone just followed you 👤',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return _notificationCard(n);
              },
            ),
    );
  }

  Widget _notificationCard(AppNotification n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          n.isRead = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xffE8F8EE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconForTitle(n.title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(n.time),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconForTitle(String title) {
    IconData icon = Icons.notifications;
    Color color = Colors.green;

    if (title.contains('goal')) icon = Icons.flag;
    if (title.contains('streak')) icon = Icons.local_fire_department;
    if (title.contains('follower')) icon = Icons.person_add;

    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ================= MODEL =================

class AppNotification {
  final String title;
  final String message;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}
