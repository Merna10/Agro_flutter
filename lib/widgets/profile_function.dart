import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

void showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: AlertDialog(
          title: const Text(
            'Confirm Account Deletion',
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 115, 44)),
          ),
          content: const Text(
            'Are you sure you want to delete your account?',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Rubik',
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 228, 9, 9)),
              ),
              onPressed: () {
                deleteAccount(context);
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: HexColor('#44ac5c')),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

void deleteAccount(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  try {
    if (user != null) {
      String? password = await _showPasswordDialog(context);

      if (password != null) {
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);

        await FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        await FirebaseFirestore.instance
            .collection('posts')
            .get()
            .then((postsSnapshot) {
          for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .collection('comments')
                .where('userId', isEqualTo: user.uid)
                .get()
                .then((commentsSnapshot) {
              for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
                commentDoc.reference.delete();
              }
            });
          }
        });
        await FirebaseFirestore.instance
            .collection('posts')
            .get()
            .then((postsSnapshot) {
          for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
            FirebaseFirestore.instance
                .collection('posts')
                .doc(postDoc.id)
                .collection('likes')
                .where('userId', isEqualTo: user.uid)
                .get()
                .then((commentsSnapshot) {
              for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
                commentDoc.reference.delete();
              }
            });
          }
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('likedPosts')
            .get()
            .then((likedPostsSnapshot) {
          for (QueryDocumentSnapshot likedPostDoc in likedPostsSnapshot.docs) {
            likedPostDoc.reference.delete();
          }
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('likedComments')
            .get()
            .then((likedPostsSnapshot) {
          for (QueryDocumentSnapshot likedPostDoc in likedPostsSnapshot.docs) {
            likedPostDoc.reference.delete();
          }
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        await user.delete();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  } catch (e) {
    String errorMessage = 'An error occurred while deleting your account.';
    if (e is FirebaseAuthException) {
      errorMessage = e.message!;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Future<String?> _showPasswordDialog(BuildContext context) async {
  TextEditingController passwordController = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Enter Password',
          style: TextStyle(
              fontSize: 20,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 26, 115, 44)),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Confirm',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 228, 9, 9)),
            ),
            onPressed: () {
              Navigator.of(context).pop(passwordController.text);
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: HexColor('#44ac5c')),
            ),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
        ],
      );
    },
  );
}
