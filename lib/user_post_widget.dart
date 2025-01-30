import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavruk/post_card.dart';

class UserPostsWidget extends StatelessWidget {
  final String userId;

  const UserPostsWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: posts.map((post) {
              var postData = post.data() as Map<String, dynamic>;
              return PostWidget(
                postId: post.id,
                imageUrl: postData['imageUrl'],
                description: postData['description'],
                rating: postData['rating'],
                postTime: postData['postTime'],
                userId: postData['userId'],
                likeCount: postData['likeCount'],
                commentCount: postData['commentCount'],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
