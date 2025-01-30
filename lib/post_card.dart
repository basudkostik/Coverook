import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kavruk/commentScreen.dart';
import 'package:kavruk/views/profile_view.dart';

class PostWidget extends StatefulWidget {
  final String postId;
  final String userId;
  final String imageUrl;
  final String description;
  final double rating;
  final Timestamp postTime;
  final int likeCount;
  final int commentCount;

  const PostWidget({
    Key? key,
    required this.postId,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.postTime,
    required this.userId,
    required this.likeCount,
    required this.commentCount,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late int _currentLikeCount;
  late int _currentCommentCount;
  bool _isLiking = false;
  bool _isBookmarked = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLikeCount = widget.likeCount;
    _currentCommentCount = widget.commentCount;
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    final doc = await FirebaseFirestore.instance
        .collection('saved')
        .doc('${widget.userId}_${widget.postId}')
        .get();
    setState(() {
      _isBookmarked = doc.exists;
    });
  }

  Future<void> _toggleBookmark() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final postId = widget.postId;

    final bookmarkDocId = '${currentUserId}_$postId';
    final bookmarkRef =
        FirebaseFirestore.instance.collection('saved').doc(bookmarkDocId);

    if (_isBookmarked) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({
        'userId': currentUserId,
        'postId': postId,
        'savedAt': Timestamp.now(),
      });
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  Future<void> _incrementLikeCount() async {
    if (_isLiking) return;
    setState(() {
      _currentLikeCount++;
      _isLiking = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'likeCount': _currentLikeCount});
    } catch (e) {
      setState(() {
        _currentLikeCount--;
        _isLiking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update likes: $e')),
      );
    }

    setState(() {
      _isLiking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        var profilePicture = userData['photoUrl'];
        String name = userData['name'] ?? 'Anonymous';

        String formattedTime =
            DateFormat('MMM d, h:mm a').format(widget.postTime.toDate());

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePicture),
                    radius: 24,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(userId: widget.userId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 0.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(widget.description),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff7f6e3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < widget.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.black,
                              size: 16,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _incrementLikeCount,
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('$_currentLikeCount'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CommentsScreen(postId: widget.postId),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          _currentCommentCount += 1;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('$_currentCommentCount'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleBookmark,
                    child: Icon(
                      Icons.bookmark,
                      color: _isBookmarked ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
