// password_update_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordUpdateScreen extends StatefulWidget {
  const PasswordUpdateScreen({super.key});
  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void updatePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: currentPassword,
      );

      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

      Navigator.pop(context);
    } catch (e) {
      _showError('Incorrect current password.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updatePassword,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
