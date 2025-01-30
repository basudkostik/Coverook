import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavruk/views/author_page.dart';
import 'package:kavruk/views/book_card_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          // Search Books
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .where('bookName', isGreaterThanOrEqualTo: query)
                  .where('bookName', isLessThanOrEqualTo: query + '\uf8ff')
                  .snapshots(),
              builder: (context, bookSnapshot) {
                if (bookSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookSnapshot.hasError) {
                  return const Center(child: Text('Error fetching books.'));
                }

                final books = bookSnapshot.data?.docs ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (books.isEmpty)
                      const Center(
                        child: Text('No books found.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final bookData = book.data() as Map<String, dynamic>;

                          return ListTile(
                            leading: Image.network(
                              bookData['bookFrontCover'] ?? '',
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(bookData['bookName'] ?? 'Unknown Title'),
                            subtitle:
                                Text(bookData['bookAuthor'] ?? 'Unknown Author'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookCardScreen(bookId: book.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(),

          // Search Authors
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('authors')
                  .where('authorName', isGreaterThanOrEqualTo: query)
                  .where('authorName', isLessThanOrEqualTo: query + '\uf8ff')
                  .snapshots(),
              builder: (context, authorSnapshot) {
                if (authorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (authorSnapshot.hasError) {
                  return const Center(child: Text('Error fetching authors.'));
                }

                final authors = authorSnapshot.data?.docs ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Authors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (authors.isEmpty)
                      const Center(
                        child: Text('No authors found.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: authors.length,
                        itemBuilder: (context, index) {
                          final author = authors[index];
                          final authorData =
                              author.data() as Map<String, dynamic>;

                          return ListTile(
                            leading: authorData['authorPhotoUrl'] != null
                                ? Image.network(
                                    authorData['authorPhotoUrl'],
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.person, size: 50),
                            title: Text(authorData['authorName'] ?? 'Unknown Author'),
                            
                            onTap: () {
                                Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AuthorPage(
                                    authorId: author.id,
                                   
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Tapped on ${authorData['authorName']}",
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
