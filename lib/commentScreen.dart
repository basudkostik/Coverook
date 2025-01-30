import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

class CommentsScreen extends StatelessWidget {
  final String postId;

  CommentsScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
  if (_commentController.text.trim().isEmpty) return;

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You must be logged in to comment.')),
    );
    return;
  }

  final comment = _commentController.text.trim();
  final commentsCollection = FirebaseFirestore.instance.collection('comments');
  final postsCollection = FirebaseFirestore.instance.collection('posts');

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Add the comment
      final newComment = commentsCollection.doc();
      transaction.set(newComment, {
        'userId': currentUser.uid,
        'postId': postId,
        'description': comment,
        'time': Timestamp.now(),
      });

      // Update the comment count
      final postDocRef = postsCollection.doc(postId);
      transaction.update(postDocRef, {
        'commentCount': FieldValue.increment(1),
      });
    });

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment added successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add comment: $e')),
    );
  }
}


    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('postId', isEqualTo: postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                devtools.log(postId);

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    var userId = data['userId'];
                    var description = data['description'];
                    var time = data['time'] as Timestamp;

                    devtools.log(description);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(description),
                            subtitle: Text(
                              DateFormat('MMM d, h:mm a').format(time.toDate()),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        }

                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(description),
                            subtitle: Text(
                              DateFormat('MMM d, h:mm a').format(time.toDate()),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        }

                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        var userPhoto = userData['photoUrl'] ?? '';
                        var userName = userData['userName'] ?? 'Unknown User';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userPhoto.isNotEmpty
                                ? NetworkImage(userPhoto)
                                : null,
                            child:
                                userPhoto.isEmpty ? Icon(Icons.person) : null,
                          ),
                          title: Text(userName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                DateFormat('MMM d, h:mm a')
                                    .format(time.toDate()),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
