import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterassignment/views/widget_tree.dart';
import 'login_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.toggleTheme});

  final Function(bool) toggleTheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return WidgetTree(toggleTheme: toggleTheme);
        }

        return LoginPage(toggleTheme: toggleTheme);
      },
    );
  }
}