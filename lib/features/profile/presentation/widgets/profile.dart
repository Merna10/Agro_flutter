import 'package:crops/features/auth/presentation/providers/user_provider.dart'; // Import your userStreamProvider
import 'package:crops/features/profile/presentation/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpecificUserWidget extends ConsumerWidget {
  final String userId;

  const SpecificUserWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(userId));

    return Scaffold(
      body: Center(
        child: userAsync.when(
          data: (user) {
            if (user != null) {
              return UserProfile(
                user: user,
                userID: userId,
              );
            } else {
              return const Text('User not found');
            }
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) {
            print('Error fetching user: $error');
            return const Text('Error fetching user data');
          },
        ),
      ),
    );
  }
}
