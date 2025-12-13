import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:growme/app/auth_state_widget.dart';
import 'package:growme/features/auth/presentation/comment_screen.dart';
import 'package:growme/features/auth/presentation/create_post_screen.dart';
import 'package:growme/features/auth/presentation/goal_Screen.dart';
import 'package:growme/features/auth/presentation/goal_summary_screen.dart';
import 'package:growme/features/auth/presentation/home_screen.dart';
import 'package:growme/features/auth/presentation/updated_goal_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF5F8F5),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xff00CC66),
        ),
      ),
      home: const AuthStateWidget(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/createPost': (_) => const CreatePostScreen(),
        '/comments': (_) => const CommentsScreen(),
        '/createGoal': (_) => const CreateGoalScreen(),
        '/goalSummary': (_) => const GoalSummaryScreen(),
        '/goals': (_) => GoalsScreen(),
      },
    );
  }
}
