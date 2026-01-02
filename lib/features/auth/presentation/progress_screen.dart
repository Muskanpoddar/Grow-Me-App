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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What's your status?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await _goalRepo.completeGoal(goal);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Mark done',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
        leading: const Icon(
          Icons.pie_chart_rounded,
          size: 28,
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_stats')
                .doc(uid)
                .snapshots(),
            builder: (_, statsSnap) {
              final streak = statsSnap.data?.exists == true
                  ? (statsSnap.data!.data()
                            as Map<String, dynamic>)['streak'] ??
                        0
                  : 0;

              return StreamBuilder<List<GoalModel>>(
                stream: _goalRepo.streamGoalsForUser(uid),
                builder: (_, goalsSnap) {
                  if (!goalsSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final goals = goalsSnap.data!;
                  final completedCount = goals
                      .where((g) => g.status == 'completed')
                      .length;

                  final today = DateTime.now();
                  final todayGoal = goals
                      .where(
                        (g) =>
                            g.status == 'active' &&
                            _sameDay(g.createdAt.toLocal(), today),
                      )
                      .cast<GoalModel?>()
                      .firstWhere((g) => g != null, orElse: () => null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= STATS =================
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.local_fire_department,
                              title: 'Current Streak',
                              value: '$streak Days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.flag,
                              title: 'Goals Completed',
                              value: completedCount.toString(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ================= TODAY GOAL =================
                      if (todayGoal != null)
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            title: Text(
                              todayGoal.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              'Tap to update status',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.more_vert),
                            onTap: () => _showStatusSheet(context, todayGoal),
                          ),
                        ),

                      _FilterPills(
                        filter: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),

                      const SizedBox(height: 20),

                      // ================= GRAPH + ACHIEVEMENTS =================
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _progressRepo.streamProgress(fromDate),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snap.data!.docs;

                            if (docs.isEmpty) {
                              return _emptyProgressState();
                            }

                            final weeklyData = {
                              for (int i = 0; i < 7; i++) i: 0,
                            };

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
                                const SizedBox(height: 24),
                                _AchievementsRow(
                                  completedCount: completedCount,
                                  streak: streak,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ================= UI COMPONENTS =================

Widget _statCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final int completedCount;
  final int streak;

  const _AchievementsRow({required this.completedCount, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _badge('🔥', 'First Step', completedCount >= 1),
              _badge('🥈', 'Consistent', streak >= 7),
              _badge('🥇', 'Champion', completedCount >= 30),
            ],
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(vertical: 10),
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

Widget _emptyProgressState() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      SizedBox(height: 40),
      Icon(Icons.insights, size: 64, color: Colors.green),
      SizedBox(height: 16),
      Text(
        'No progress yet',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text(
        'Complete your first goal to see progress here',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _badge(String emoji, String label, bool unlocked) {
  return Container(
    margin: const EdgeInsets.only(right: 14),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: unlocked
          ? Colors.green.withOpacity(0.15)
          : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: unlocked ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
