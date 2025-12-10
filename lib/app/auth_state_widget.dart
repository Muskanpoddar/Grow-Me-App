import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/presentation/auth_screen.dart';
import 'package:growme/features/auth/presentation/home_screen.dart';

class AuthStateWidget extends StatelessWidget {
  const AuthStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // if user logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // if user not logged in
        return const AuthScreen();
      },
    );
  }
}
