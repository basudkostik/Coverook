import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavruk/views/profile_view.dart';

class FollowPage extends StatelessWidget {
  final String title; // "Followers" or "Following"
  final String queryKey; // Either "myUserId" or "followingUserId"
  final String userId; // Current user's ID

  FollowPage({
    required this.title,
    required this.queryKey,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.brown[200],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('followings')
            .where(queryKey, isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No ${title.toLowerCase()} found.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            );
          }

          final followDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: followDocs.length,
            itemBuilder: (context, index) {
              final followData = followDocs[index].data() as Map<String, dynamic>;
              final otherUserId = queryKey == 'myUserId'
                  ? followData['followingUserId']
                  : followData['myUserId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(),
                      title: Text('Loading...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['photoUrl'] != null &&
                              userData['photoUrl'].isNotEmpty
                          ? NetworkImage(userData['photoUrl'])
                          : const AssetImage('assets/images/blank.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      userData['name'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('@${userData['userName']}'),
                    onTap: () {
                      // Navigate to the selected user's profile
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: otherUserId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
