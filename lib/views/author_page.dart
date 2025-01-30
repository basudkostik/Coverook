import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_card_screen.dart'; // Import the BookCardScreen here

class AuthorPage extends StatelessWidget {
  final String authorId; // Author's unique ID
  const AuthorPage({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Author Details"),
        backgroundColor: const Color(0xFFBF9E8A),
      ),
      backgroundColor: const Color(0xFFBF9E8A),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('authors').doc(authorId).get(),
        builder: (context, authorSnapshot) {
          if (authorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authorSnapshot.hasData || !authorSnapshot.data!.exists) {
            return const Center(
              child: Text(
                "Author not found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final authorData = authorSnapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F6E3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: authorData['authorPhotoUrl'] != null
                            ? NetworkImage(authorData['authorPhotoUrl'])
                            : const AssetImage('assets/default_author.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authorData['authorName'] ?? "Unknown Author",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authorData['bio'] ?? "No biography available.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Books Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Books by this Author",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('bookAuthor', isEqualTo: authorData['authorName'])
                      .snapshots(),
                  builder: (context, booksSnapshot) {
                    if (booksSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!booksSnapshot.hasData || booksSnapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        alignment: Alignment.center,
                        child: const Text(
                          "No books found for this author.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    final books = booksSnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return InkWell(
                          onTap: () {
                            // Navigate to the BookCardScreen with bookId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookCardScreen(bookId: book.id),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Image.network(
                              book['bookFrontCover'],
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              book['bookName'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
