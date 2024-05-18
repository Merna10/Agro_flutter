import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crops/screens/auth.dart';
import 'package:crops/screens/predict_screen.dart';
import 'package:crops/widgets/profile.dart';
import 'package:crops/screens/search.dart';
import 'package:crops/screens/categories.dart';
import 'package:crops/screens/new_post.dart';
import 'package:crops/screens/posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const PostsScreen(),
    const CropsCategoryItem(),
    const PredictScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Agro",
          style: GoogleFonts.rubik(
            textStyle: const TextStyle(
              fontSize: 45,
              color: Color.fromARGB(255, 26, 115, 44),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewPost(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/OIP (3).jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(''),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecificUserWidget(
                        userId: user.uid,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Prediction'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PredictScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Search'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('LogOut'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label),
            label: 'Types',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_photo_alternate),
            label: 'Predict',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: HexColor('#3c604a'),
        onTap: _onItemTapped,
      ),
    );
  }
}
