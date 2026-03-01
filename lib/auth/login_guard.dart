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
        content: const Text(
          'Create an account or login to use this feature. You can continue browsing as guest.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Login / Register'),
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
