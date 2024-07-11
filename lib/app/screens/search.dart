import 'package:crops/app/routes/routes.dart';
import 'package:crops/core/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot<Object?>> _searchResults = [];

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        final List<DocumentSnapshot> filteredResults = [];

        querySnapshot.docs.forEach((userSnapshot) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          String username = userData['username'] ?? '';

          // Perform a case-insensitive check
          if (username.toLowerCase().contains(query.toLowerCase())) {
            filteredResults.add(userSnapshot);
          }
        });

        setState(() {
          _searchResults = filteredResults;
        });
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _navigateToUserProfile(DocumentSnapshot userSnapshot) {
  var userData = userSnapshot.data() as Map<String, dynamic>;
  Users user = Users(
    username: userData['username'],
    email: userData['email'],
    userImage: userData['userImage'],
  );
  String userID = userSnapshot.id;

  Navigator.pushNamed(
    context,
    Routes.userProfile,
    arguments: {'user': user, 'userID': userID},
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Users',
          style: GoogleFonts.rubik(
            textStyle: const TextStyle(
              fontSize: 35,
              color: Color.fromARGB(255, 26, 115, 44),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _performSearch(value),
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter username',
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 26, 115, 44)),
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 26, 115, 44)),
                prefixIcon: const Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: HexColor('#44ac5c')), // Change color when focused
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 26, 115, 44)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                var userData =
                    _searchResults[index].data() as Map<String, dynamic>?;
                return ListTile(
                  title: Text(userData?['username'] ?? 'No Username'),
                  leading: Image.network(
                    userData?['userImage'],
                    height: 50,
                    width: 50,
                  ),
                  onTap: () {
                    _navigateToUserProfile(_searchResults[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
