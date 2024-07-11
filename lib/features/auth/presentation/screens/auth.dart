import 'package:crops/core/models/user.dart';
import 'package:crops/app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_button/sign_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _form = GlobalKey<FormState>();

  final TextEditingController _enteredEmail = TextEditingController();
  final TextEditingController _enteredPassword = TextEditingController();
  final TextEditingController _enteredUsername = TextEditingController();

  final String _defaultAvatar =
      'https://firebasestorage.googleapis.com/v0/b/basic-8dee0.appspot.com/o/user_images%2FR.png?alt=media&token=f758be71-1c2b-4fd4-97e9-e8f279a346dc';

  var _isAuthenticating = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (_isLogin) {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail.text,
          password: _enteredPassword.text,
        );

        if (userCredential.user!.emailVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified. Please check your email.'),
            ),
          );
        }
      } else {
        final UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _enteredEmail.text,
          password: _enteredPassword.text,
        );

        await userCredential.user!.sendEmailVerification();

        Users user = Users(
          email: _enteredEmail.text,
          username: _enteredUsername.text,
          userImage: _defaultAvatar,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Verification email sent. Please verify your email before logging in.'),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_enteredEmail.text.isEmpty || !_enteredEmail.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: _enteredEmail.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final userDoc =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final userSnapshot = await userDoc.get();

          if (!userSnapshot.exists) {
            Users newUser = Users(
              email: userCredential.user!.email!,
              username: user.displayName ?? 'User',
              userImage: user.photoURL ?? _defaultAvatar,
            );

            await userDoc.set(newUser.toMap());
          }

          if (user.emailVerified) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email not verified. Please check your email.'),
              ),
            );
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${error.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 250, 248),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/OIP (3).jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenHeight,
                  color: const Color.fromARGB(95, 30, 154, 47),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                        left: 16,
                        top: 150,
                      ),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Welcome",
                              style: GoogleFonts.atma(
                                textStyle: const TextStyle(
                                    fontSize: 80, color: Colors.white),
                              ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              style: const TextStyle(color: Colors.white),
                              controller: _enteredEmail,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              controller: _enteredPassword,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontSize: 20),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                controller: _enteredUsername,
                              ),
                            const SizedBox(height: 12),
                            if (_isLogin)
                              TextButton(
                                onPressed: _resetPassword,
                                child: const Text(
                                  'Forget Password?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      const Size(235.0, 20.0)),
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 231, 232, 233)),
                                  foregroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 26, 115, 44)),
                                  textStyle:
                                      MaterialStateProperty.all<TextStyle>(
                                    const TextStyle(fontSize: 16),
                                  ),
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                  ),
                                ),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            SignInButton(
                              buttonType: ButtonType.google,
                              onPressed: _signInWithGoogle,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
