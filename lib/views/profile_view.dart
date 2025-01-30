import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavruk/constants/routers.dart';
import 'package:kavruk/favourites_widget.dart';
import 'package:kavruk/user/auth_service.dart';
import 'package:kavruk/user_post_widget.dart';
import 'package:kavruk/utilities/logout_dialog.dart';
import 'package:kavruk/views/follow_view.dart';

class ProfileScreen extends StatelessWidget {
  final String userId; // Pass userId dynamically to fetch data for a specific user

  ProfileScreen({required this.userId});

  void navigateToFollowPage(BuildContext context, String title, String key) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowPage(
          title: title,
          queryKey: key,
          userId: userId,
        ),
      ),
    );
  }

  Future<void> handleFollow(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final myUserId = currentUser.uid;
    final followerUserId = userId;

    try {
      final followingsRef = FirebaseFirestore.instance.collection('followings');
      final myUserRef = FirebaseFirestore.instance.collection('users').doc(myUserId);
      final followerUserRef = FirebaseFirestore.instance.collection('users').doc(followerUserId);

      // Check if already following
      final existingFollow = await followingsRef
          .where('myUserId', isEqualTo: myUserId)
          .where('followingUserId', isEqualTo: followerUserId)
          .get();

      if (existingFollow.docs.isEmpty) {
        // Add to followings table
        await followingsRef.add({
          'myUserId': myUserId,
          'followingUserId': followerUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update counts
        await myUserRef.update({'followingCount': FieldValue.increment(1)});
        await followerUserRef.update({'followerCount': FieldValue.increment(1)});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are now following ${followerUserId}!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are already following this user.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture and Info Section in Banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBF9E8A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userData['photoUrl'] != null &&
                            userData['photoUrl'].isNotEmpty
                            ? NetworkImage(userData['photoUrl'])
                            : const AssetImage('assets/images/blank.png') as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData['name'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '@${userData['userName']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => navigateToFollowPage(
                                context, 'Following', 'myUserId'),
                            child: Column(
                              children: [
                                Text(
                                  (userData['followingCount'] ?? 0).toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                ),
                                const Text('Following',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => navigateToFollowPage(
                                context, 'Followers', 'followingUserId'),
                            child: Column(
                              children: [
                                Text(
                                  (userData['followerCount'] ?? 0).toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                ),
                                const Text('Followers',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Follow Button
                ElevatedButton(
                  onPressed: () => handleFollow(context),
                  child: const Text('Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Favorites Section
                FavouritesWidget(userId: userId),

                // Recent Posts Section
                UserPostsWidget(userId: userId),
              ],
            ),
          );
        },
      ),
    );
  }
}
