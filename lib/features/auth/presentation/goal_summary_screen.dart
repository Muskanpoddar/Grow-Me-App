import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/domain/models/goal_model.dart';
import 'package:growme/features/auth/presentation/home_screen.dart';

class GoalSummaryScreen extends StatelessWidget {
  const GoalSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GoalModel goal =
        ModalRoute.of(context)!.settings.arguments as GoalModel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Goal Created',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      const SizedBox(height: 12),

                      if (goal.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            goal.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      if (goal.description != null &&
                          goal.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          goal.description!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Text(
                        'Category: ${goal.category}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Deadline: ${goal.deadline.day}-${goal.deadline.month}-${goal.deadline.year}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          initialIndex: 2, // 🔥 Progress tab
                        ),
                      ),
                      (route) => false,
                    );
                  },

                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
