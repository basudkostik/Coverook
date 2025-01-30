import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavruk/chatScreen.dart';

import 'package:kavruk/explore_page.dart';
 
import 'package:kavruk/views/add_page.dart';
import 'package:kavruk/views/alerts_page.dart';
 
import 'package:kavruk/views/bookMarkMenu.dart';
import 'package:kavruk/views/homepagescreen.dart';
 
import 'package:kavruk/views/panelMenu.dart';
import 'package:kavruk/views/profile_view.dart';
import 'package:kavruk/views/search_result_screen.dart';
import 'package:kavruk/views/settingsMenu.dart';

class CoverookHomePage extends StatefulWidget {
  const CoverookHomePage({super.key});

  @override
  _CoverookHomePageState createState() => _CoverookHomePageState();
}

class _CoverookHomePageState extends State<CoverookHomePage> {
  int _selectedIndex = 0;
  bool isSearching = false;
  String searchQuery = "";
  bool isSeller = false;

  @override
  void initState() {
    super.initState();
    _checkIsSeller();
  }

  Future<void> _checkIsSeller() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          isSeller = userDoc.data()?['isSeller'] ?? false;
        });
      }
    }
  }

  final List<Widget> _pages = [
    HomePage(),
    ExplorePage(),
    AddPage(),
    ChatScreen(),
    AlertsPage(),
    ProfileScreen(userId: FirebaseAuth.instance.currentUser!.uid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBF9E8A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearching
            ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = "";
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });

            if (value.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(query: value),
                ),
              );
            }
          },
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Coverook',
              style: TextStyle(
                fontFamily: 'BlackMango',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.brown,
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isSeller)
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Panel'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PanelMenu(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved Posts'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BookmarkMenu(), // bookmarkMenu.dart'taki sınıf
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                    builder: (context) => const SettingsMenu(),
                    ),
                );// bookmarkMenu.dart'taki sınıf
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                // Add Log Out logic
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown[300],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.umbrella), label: 'Advice'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
