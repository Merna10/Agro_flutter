import 'package:crops/core/models/user.dart';
import 'package:crops/features/profile/presentation/screens/password_update_screen.dart';
import 'package:crops/features/profile/presentation/screens/updateprofile.dart';
import 'package:crops/features/profile/presentation/widgets/profile_function.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';

class ProfilePopupMenu extends StatelessWidget {
  final Users user;
  final String userID;

  const ProfilePopupMenu({
    super.key,
    required this.user,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (userID == FirebaseAuth.instance.currentUser?.uid) {
          return PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'editProfile',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'changePassword',
                child: ListTile(
                  leading: Icon(Icons.vpn_key),
                  title: Text('Change Password'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'deleteAccount',
                child: ListTile(
                  leading: Icon(Icons.delete_forever),
                  title: Text('Delete Account'),
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'editProfile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      userId: userID,
                      username: user.username,
                      userImage: user.userImage,
                    ),
                  ),
                );
              } else if (value == 'changePassword') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordUpdateScreen(),
                  ),
                );
              } else if (value == 'deleteAccount') {
                showConfirmationDialog(context);
              }
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
