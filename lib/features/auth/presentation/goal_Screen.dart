import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/core/goal_model.dart';
import '../data/goal_repository.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalRepository _repo = GoalRepository();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<GoalModel>>(
              stream: _repo.streamGoalsForUser(uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text(snap.error.toString()));
                }

                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final goals = snap.data!;
                final now = DateTime.now();

                // 🔥 Find today’s active goal
                final GoalModel? todayGoal = goals
                    .cast<GoalModel?>()
                    .firstWhere(
                      (g) =>
                          g!.status == 'active' && _isSameDay(g.createdAt, now),
                      orElse: () => null,
                    );

                // Older goals (excluding today)
                final pastGoals = goals.where((g) => g != todayGoal).toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= TODAY GOAL =================
                      if (todayGoal != null) ...[
                        const Text(
                          "Today's Goal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: const Color(0xffEAF8ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            title: Text(
                              todayGoal.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Deadline: ${todayGoal.deadline.day}-${todayGoal.deadline.month}-${todayGoal.deadline.year}',
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // ================= NO GOAL TODAY =================
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "You haven’t set a goal today",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/createGoal');
                                },
                                child: const Text('+ Set Today’s Goal'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ================= PAST GOALS =================
                      if (pastGoals.isNotEmpty) ...[
                        const Text(
                          "Previous Goals",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: pastGoals.length,
                            itemBuilder: (c, i) {
                              final g = pastGoals[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(
                                    g.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Deadline: ${g.deadline.day}-${g.deadline.month}-${g.deadline.year}',
                                  ),
                                  trailing: Text(
                                    g.status,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
