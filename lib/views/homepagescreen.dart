import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavruk/home_tabs/following_tab.dart';
import 'package:kavruk/home_tabs/news_tab.dart';
import 'package:kavruk/user/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = [
    FollowingsTab(myUserId: FirebaseAuth.instance.currentUser!.uid,),
    const NewsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffbf9e8a),
      appBar: AppBar(
        backgroundColor: const Color(0xffbf9e8a),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildBannerButton("Followings", 0)),
            const SizedBox(width: 10),
            const SizedBox(width: 10),
            Expanded(child: _buildBannerButton("News", 1)),
          ],
        ),
      ),
      body: _tabs[_selectedTabIndex],
    );
  }

  Widget _buildBannerButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _selectedTabIndex == index ? Colors.white : const Color(0xfff7f6e3),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: _selectedTabIndex == index ? Colors.black : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




