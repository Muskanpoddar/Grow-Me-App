import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/features/auth/domain/models/goal_model.dart';
import '../data/goal_repository.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final repo = GoalRepository();

    if (uid == null) {
      return const Center(child: Text('Please log in'));
    }

    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      body: StreamBuilder<List<GoalModel>>(
        stream: repo.streamGoalsForUser(uid),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snap.data!;
          final now = DateTime.now();

          GoalModel? todayGoal;
          final List<GoalModel> pastGoals = [];

          for (final g in goals) {
            if (g.status == 'active' && _isSameDay(g.createdAt, now)) {
              todayGoal = g;
            } else {
              pastGoals.add(g);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ================= HEADER =================
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Goals',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= CREATE GOAL BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      "Create Today's Goal",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: todayGoal != null
                        ? null
                        : () => Navigator.pushNamed(context, '/createGoal'),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= TODAY GOAL =================
              if (todayGoal != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Today's Goal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      todayGoal.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Deadline: ${todayGoal.deadline.day}-${todayGoal.deadline.month}-${todayGoal.deadline.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],

              // ================= PREVIOUS GOALS =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Previous Goals",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: pastGoals.isEmpty
                    ? const Center(
                        child: Text(
                          'No previous goals yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pastGoals.length,
                        itemBuilder: (c, i) {
                          final g = pastGoals[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              title: Text(
                                g.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Deadline: ${g.deadline.day}-${g.deadline.month}-${g.deadline.year}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  g.status,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
