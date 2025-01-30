import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavruk/constants/routers.dart';
import 'package:kavruk/user/auth_service.dart';
import 'dart:developer' as devtools show log;

class AdditionalInfoView extends StatefulWidget {
  const AdditionalInfoView({super.key});

  @override
  State<AdditionalInfoView> createState() => _AdditionalInfoViewState();
}

class _AdditionalInfoViewState extends State<AdditionalInfoView> {
  late final TextEditingController _userNameController;
  late final TextEditingController _nameSurnameController;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _nameSurnameController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _nameSurnameController.dispose();
    super.dispose();
  }

  Future<void> saveUserInfo(String userName, String name) async {
    final user = AuthService.firebase().currentUser;
    if (user == null || user.id.isEmpty) {
      devtools.log('Error: User is not logged in or userId is null.');
      throw Exception('User ID is required to save data.');
    }

    final userId = user.id;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': name,
        'userId': userId,
        'userName': userName,
        'accountCreationTime': FieldValue.serverTimestamp(),
        'photoUrl': '',
        'isSeller': false,
        'email': user.email,
        'isEmailVerified': user.isEmailVerified,
        'followingCount': 0,
        'followerCount': 0,
        'booksCount': 0,
        'likesCount': 0,
      });
      devtools.log('User info saved successfully!');
    } catch (e) {
      devtools.log('Failed to save user info: $e');
      throw Exception('Failed to save user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/empty_back.png'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _userNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black54,
                  hintText: 'Enter your username',
                  hintStyle: const TextStyle(color: Colors.white70),
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameSurnameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black54,
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(color: Colors.white70),
                  labelText: 'Name and Surname',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  final userName = _userNameController.text.trim();
                  final name = _nameSurnameController.text.trim();

                  if (userName.isEmpty || name.isEmpty) {
                    devtools.log('Error: Username or Name is empty.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields.')),
                    );
                    return;
                  }
                  try {
                    await saveUserInfo(userName, name);
                    devtools.log('Navigating to home page...');
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      homepageRoute,
                      (route) => false,
                    );
                  } catch (e) {
                    devtools.log('Error while saving info: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save info.')),
                    );
                  }
                },
                child: const Text('Save Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
