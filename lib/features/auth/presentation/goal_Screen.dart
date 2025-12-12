import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growme/core/goal_model.dart';
import '../data/goal_repository.dart';

class GoalsScreen extends StatelessWidget {
  final GoalRepository _repo = GoalRepository();

  GoalsScreen({Key? key}) : super(key: key);

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
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final goals = snap.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: goals.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text("No goals yet.\nTap + New Goal to add one.", textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/createGoal'), child: const Text('+ New Goal')),
                          ]),
                        )
                      : ListView.builder(
                          itemCount: goals.length,
                          itemBuilder: (c, i) {
                            final g = goals[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  if (g.description != null) Text(g.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Text('Deadline: ${g.deadline.day}-${g.deadline.month}-${g.deadline.year}', style: const TextStyle(color: Colors.green)),
                                ]),
                                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(g.status, style: const TextStyle(color: Colors.green)),
                                ]),
                                onTap: () {
                                  // optionally view detail
                                },
                              ),
                            );
                          },
                        ),
                );
              },
            ),
      floatingActionButton: null, // no FAB here (user adds via New Goal button)
    );
  }
}
