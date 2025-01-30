import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../post_card.dart';

class BookmarkMenu extends StatelessWidget {
  const BookmarkMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Posts"),
        backgroundColor: Colors.brown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('saved')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedDocs = snapshot.data!.docs;

          if (savedDocs.isEmpty) {
            return const Center(
              child: Text(
                "No saved posts yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: savedDocs.length,
            itemBuilder: (context, index) {
              final savedData = savedDocs[index].data() as Map<String, dynamic>;
              final postId = savedData['postId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!postSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final postData = postSnapshot.data!.data() as Map<String, dynamic>;

                  return PostWidget(
                    postId: postId,
                    userId: postData['userId'],
                    imageUrl: postData['imageUrl'],
                    description: postData['description'],
                    rating: (postData['rating'] as num).toDouble(),
                    postTime: postData['postTime'],
                    likeCount: postData['likeCount'],
                    commentCount: postData['commentCount'],
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
