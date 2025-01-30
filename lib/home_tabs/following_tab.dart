import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavruk/post_card.dart';
// Import the PostWidget file

class FollowingsTab extends StatefulWidget {
  final String myUserId;

  FollowingsTab({super.key, required this.myUserId});

  @override
  _FollowingsTabState createState() => _FollowingsTabState();
}

class _FollowingsTabState extends State<FollowingsTab> {
  late Future<List<DocumentSnapshot>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = getFollowings(widget.myUserId).then((followingUserIds) {
      return getPostsFromFollowings(followingUserIds);
    });
  }

  Future<List<String>> getFollowings(String myUserId) async {
    List<String> followingUserIds = [];

    // Fetch followings where the logged-in user is the 'myUserId'
    QuerySnapshot followingsSnapshot = await FirebaseFirestore.instance
        .collection('followings')
        .where('myUserId', isEqualTo: myUserId)
        .get();

    // Extract followingUserIds from the fetched followings
    for (var doc in followingsSnapshot.docs) {
      followingUserIds.add(doc['followingUserId']);
    }

    return followingUserIds;
  }

  Future<List<DocumentSnapshot>> getPostsFromFollowings(
      List<String> followingUserIds) async {
    List<DocumentSnapshot> posts = [];

    if (followingUserIds.isEmpty) return posts;

    // Fetch posts made by followed users
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId',
            whereIn: followingUserIds) // Fetch posts by followed users
        .get();

    posts.addAll(postsSnapshot.docs);

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Followings Posts")),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No posts from followed users."));
          }

          List<DocumentSnapshot> posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var postData = posts[index].data() as Map<String, dynamic>;

              return PostWidget(
                postId: posts[index].id,
                userId: postData['userId'],
                imageUrl: postData['imageUrl'],
                description: postData['description'],
                rating: postData['rating'],
                postTime: postData['postTime'],
                likeCount: postData['likeCount'],
                commentCount: postData['commentCount'],
              );
            },
          );
        },
      ),
    );
  }
}
