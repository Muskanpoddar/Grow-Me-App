import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growme/core/utils/time_filter.dart';
import 'package:growme/features/auth/data/progress_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  TimeFilter _filter = TimeFilter.week;
  final repo = ProgressRepository();

  @override
  Widget build(BuildContext context) {
    final fromDate = getStartDate(_filter);

    return Scaffold(
      backgroundColor: const Color(0xffF5F8F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Progress",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            _buildFilter(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: repo.streamProgress(fromDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No progress yet"));
                  }

                  final docs = snapshot.data!.docs;

                  return _buildContent(docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FILTER ----------------
  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: TimeFilter.values.map((f) {
          final selected = _filter == f;
          return ChoiceChip(
            label: Text(f.name.toUpperCase()),
            selected: selected,
            selectedColor: Colors.green,
            onSelected: (_) => setState(() => _filter = f),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- CONTENT ----------------
  Widget _buildContent(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> skillTotals = {};
    final List<Map<String, dynamic>> activities = [];

    for (final d in docs) {
      final skill = d['skills'] as String;
      final value = (d['value'] as num).toDouble();
      final date = (d['createdAt'] as Timestamp).toDate();

      skillTotals[skill] = (skillTotals[skill] ?? 0) + value;

      activities.add({'skill': skill, 'value': value, 'date': date});
    }

    final totalHours = skillTotals.values.fold(0.0, (a, b) => a + b);
    final streak = _calculateStreak(activities);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatsCard(totalHours: totalHours, streak: streak),

        const SizedBox(height: 20),

        const Text(
          "Skill Progress",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...skillTotals.entries.map(
          (e) => _SkillCard(skill: e.key, total: e.value),
        ),

        const SizedBox(height: 24),

        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...activities.reversed
            .take(5)
            .map(
              (a) => _ActivityTile(
                skill: a['skill'],
                value: a['value'],
                date: a['date'],
              ),
            ),
      ],
    );
  }

  // ---------------- STREAK ----------------
  int _calculateStreak(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty) return 0;

    activities.sort((a, b) => b['date'].compareTo(a['date']));

    int streak = 1;
    DateTime last = activities.first['date'];

    for (int i = 1; i < activities.length; i++) {
      final current = activities[i]['date'];
      if (last.difference(current).inDays == 1) {
        streak++;
        last = current;
      } else {
        break;
      }
    }

    return streak;
  }
}

// ================= UI COMPONENTS =================

class _StatsCard extends StatelessWidget {
  final double totalHours;
  final int streak;

  const _StatsCard({required this.totalHours, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(label: "Total Hours", value: totalHours.toStringAsFixed(1)),
          _StatItem(label: "Current Streak", value: "$streak days"),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String skill;
  final double total;

  const _SkillCard({required this.skill, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (total / 50).clamp(0, 1),
            color: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(height: 6),
          Text("${total.toStringAsFixed(1)} hrs"),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String skill;
  final double value;
  final DateTime date;

  const _ActivityTile({
    required this.skill,
    required this.value,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(skill),
      subtitle: Text("${value.toStringAsFixed(1)} hrs"),
      trailing: Text("${date.day}/${date.month}"),
    );
  }
}
