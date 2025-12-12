import 'package:flutter/material.dart';
import 'package:growme/core/goal_model.dart';

class GoalSummaryScreen extends StatelessWidget {
  const GoalSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoalModel goal =
        ModalRoute.of(context)!.settings.arguments as GoalModel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text(
                'Goal Created',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (goal.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(goal.imageUrl!),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        goal.description ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${goal.category}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deadline: ${goal.deadline.day}-${goal.deadline.month}-${goal.deadline.year}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 36,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  // pop back to goals screen; we used pushReplacement earlier so just navigate to goals route
                  Navigator.pushReplacementNamed(context, '/goals');
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
