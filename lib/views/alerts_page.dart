import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final List<Map<String, dynamic>> notifications = [];

    // Fetch Followings Notifications
    final followingsSnapshot = await FirebaseFirestore.instance
        .collection('followings')
        .where('followingUserId', isEqualTo: currentUserId)
        .get();

    for (var doc in followingsSnapshot.docs) {
      final data = doc.data();
      final userId = data['myUserId'];
      final username = await _fetchUsername(userId);
      notifications.add({
        "message": "@$username has followed you!",
        "timestamp": (data['timestamp'] as Timestamp).toDate(),
      });
    }

    // Fetch user's posts to get postIds
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: currentUserId)
        .get();

    final postIds = postsSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch Comments Notifications for user's posts
    for (var i = 0; i < postIds.length; i += 10) {
      final chunk = postIds.sublist(i, i + 10 > postIds.length ? postIds.length : i + 10);

      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', whereIn: chunk)
          .orderBy('time', descending: true)
          .get();

      for (var doc in commentsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'];
        final username = await _fetchUsername(userId);
        notifications.add({
          "message": "@$username commented on your post!",
          "timestamp": (data['time'] as Timestamp).toDate(),
        });
      }
    }

    // Sort notifications by time
    notifications.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return notifications;
  }

  Future<String> _fetchUsername(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final userData = userSnapshot.data();
    return userData?['userName'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFBF9E8A),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "An error occurred: ${snapshot.error}",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  "No notifications yet.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final message = notification['message'] as String;
                final timestamp = notification['timestamp'] as DateTime;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFBF9E8A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatTimestamp(timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }
}
