import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:growme/core/utils/time_filter.dart';
import 'package:growme/features/auth/data/goal_repository.dart';
import 'package:growme/features/auth/domain/models/goal_model.dart';
import 'package:growme/features/auth/presentation/weekly_progress_chart.dart';
import '../data/progress_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  final _progressRepo = ProgressRepository();
  final _goalRepo = GoalRepository();

  TimeFilter _filter = TimeFilter.week;

  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ================= STATUS SHEET =================
  void _showStatusSheet(BuildContext context, GoalModel goal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What's your status?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await _goalRepo.completeGoal(goal);
                  Navigator.pop(context);
                },
                child: const Text('Mark done'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Still working'),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () async {
                  await _goalRepo.updateGoalStatus(
                    goal: goal,
                    status: 'skipped',
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Skip for today',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fromDate = getStartDate(_filter);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        leading: Icon(
          Icons.pie_chart_rounded,
          size: 30,
          color: Color(0xff00CC66),
        ),
        title: const Text(
          'Progress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= STATS =================
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user_stats')
                    .doc(uid)
                    .snapshots(),
                builder: (_, snap) {
                  final streak = snap.data?.exists == true
                      ? (snap.data!.data() as Map<String, dynamic>)['streak'] ??
                            0
                      : 0;

                  return StreamBuilder<QuerySnapshot>(
                    stream: _progressRepo.streamProgress(DateTime(2000)),
                    builder: (_, pSnap) {
                      final completed = pSnap.data?.docs.length ?? 0;

                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department,
                              title: 'Current Streak',
                              value: '$streak Days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flag,
                              title: 'Goals Completed',
                              value: completed.toString(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 18),

              // ================= TODAY GOAL =================
              StreamBuilder<List<GoalModel>>(
                stream: _goalRepo.streamGoalsForUser(uid),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox();

                  final today = DateTime.now();
                  final goal = snap.data!
                      .where(
                        (g) =>
                            g.status == 'active' &&
                            _sameDay(g.createdAt.toLocal(), today),
                      )
                      .cast<GoalModel?>()
                      .firstWhere((g) => g != null, orElse: () => null);

                  if (goal == null) return const SizedBox();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        goal.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Tap to update status'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () => _showStatusSheet(context, goal),
                    ),
                  );
                },
              ),

              // ================= FILTER =================
              _FilterPills(
                filter: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),

              const SizedBox(height: 18),

              // ================= CONTENT =================
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _progressRepo.streamProgress(fromDate),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;

                    final weeklyData = {for (int i = 0; i < 7; i++) i: 0};

                    for (final d in docs) {
                      final date = (d['createdAt'] as Timestamp)
                          .toDate()
                          .toLocal();
                      weeklyData[date.weekday - 1] =
                          weeklyData[date.weekday - 1]! + 1;
                    }

                    return ListView(
                      children: [
                        _SectionCard(
                          title: 'Weekly Progress',
                          child: WeeklyProgressChart(data: weeklyData),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (docs.isEmpty)
                          const Center(
                            child: Text(
                              'No progress yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ...docs.map(
                          (d) => _HistoryCard(
                            title: d['skill'],
                            date: (d['createdAt'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 10),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= UI COMPONENTS =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEAF8ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String date;

  const _HistoryCard({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final TimeFilter filter;
  final ValueChanged<TimeFilter> onChanged;

  const _FilterPills({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: TimeFilter.values.map((f) {
          final selected = f == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    f.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.green : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
