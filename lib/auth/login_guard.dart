import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

Future<bool> requireLogin(BuildContext context) async {
  if (FirebaseAuth.instance.currentUser != null) {
    return true;
  }

  final shouldLogin = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login first to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Login'),
          ),
        ],
      );
    },
  );

  if (shouldLogin != true) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );

  return FirebaseAuth.instance.currentUser != null;
}
