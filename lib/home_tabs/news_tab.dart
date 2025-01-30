import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavruk/post_card.dart';
 

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  late Future<List<DocumentSnapshot>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = getPosts(); // Fetch all posts
  }

  Future<List<DocumentSnapshot>> getPosts() async {
    // Fetch all posts from the 'posts' collection
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('postTime', descending: true) // Optionally order by post time
        .get();

    return postsSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Posts")),
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
            return Center(child: Text("No posts available."));
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
