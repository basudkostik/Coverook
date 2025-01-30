import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavruk/book_card.dart';

class BookCardScreen extends StatelessWidget {
  final String bookId;

  const BookCardScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBF9E8A),
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(context);
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyState();
          }

          final bookData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildBookDetails(bookData);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.brown,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Error loading book data.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book_outlined, color: Colors.grey, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Book not found.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBookDetails(Map<String, dynamic> bookData) {
    return BookCard(
      bookName: bookData['bookName'] ?? 'Unknown Title',
      bookAuthor: bookData['bookAuthor'] ?? 'Unknown Author',
      bookDescription: bookData['bookDescription'] ?? 'No description available.',
      bookCommentsNumber: bookData['bookCommentsNumber'] ?? 0,
      bookRatings: (bookData['bookRatings'] ?? 0).toDouble(),
      bookRatingsNumber: bookData['ratingsNumber'] ?? 0,
      bookBackcover: bookData['bookBackCover'] ?? '',
      bookFrontcover: bookData['bookFrontCover'] ?? '',
    );
  }
}
