import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String selectedOption = "";
  String bookCover = "";
  bool isSpoiler = false;
  final String placeholderImageUrl =
      "https://via.placeholder.com/150/FFC0CB/FFFFFF";
  TextEditingController _descriptionController = TextEditingController();

  // Function to save the post to Firestore
  void _savePost() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty ||
        (selectedOption == "Books" && bookCover.isEmpty)) {
      // Show an error if description or cover (for Books) is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description or cover cannot be empty")),
      );
      return;
    }

    try {
      // Get the current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Get the current timestamp
        final postTime = Timestamp.now();

        // Save to Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'description': description,
          'imageUrl':
          selectedOption == "Independent" ? placeholderImageUrl : bookCover,
          'postTime': postTime,
          'userId': userId,
          'commentCount': 0,
          'likeCount': 0,
          'rating': 4.8,
          'category': selectedOption,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post successfully added!")),
        );

        // Clear the form after successful submission
        _descriptionController.clear();
        setState(() {
          selectedOption = "";
          bookCover = "";
        });
      } else {
        // User not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving post: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Opinion",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBF9E8A),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isSpoiler
                        ? const Color(0xFFD8D8D5)
                        : const Color(0xFFF7F6E3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF725746),
                        blurRadius: 6,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF725746),
                        blurRadius: 6,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Spoiler",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: isSpoiler,
                            onChanged: (value) {
                              setState(() {
                                isSpoiler = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Write your opinion here...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      if (selectedOption == "Books" && bookCover.isNotEmpty)
                        Column(
                          children: [
                            Image.network(
                              bookCover,
                              height: 150,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                selectedOption = "Books";
                              });
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchPage(),
                                ),
                              );
                              if (result != null && result is String) {
                                setState(() {
                                  bookCover = result;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBFBFBF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Books",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedOption = "Independent";
                                bookCover = ""; // No cover required
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBFBFBF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Independent",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _savePost, // Save post when clicked
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBF9E8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save Post",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  String bookCover = "";

  void _searchBooks(String query) async {
    if (query.isNotEmpty) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('books') // Replace with your Firestore collection name
            .where('bookName', isGreaterThanOrEqualTo: query)
            .where('bookName',
            isLessThanOrEqualTo: query +
                '\uf8ff') // To search for titles starting with the query
            .get();

        setState(() {
          _books = snapshot.docs
              .map((doc) => {
            'bookName': doc['bookName'],
            'bookBackCover': doc[
            'bookBackCover'], // Adjust based on your Firestore structure
          })
              .toList();
        });
      } catch (e) {
        print("Error searching books: $e");
      }
    } else {
      setState(() {
        _books = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Books",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter book name...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _searchBooks(value);
              },
            ),
            const SizedBox(height: 16),
            if (_books.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                      Image.network(_books[index]['bookBackCover'] ?? ''),
                      title: Text(_books[index]['bookName'] ?? ''),
                      onTap: () {
                        setState(() {
                          bookCover = _books[index]['bookBackCover'] ?? '';
                        });
                        Navigator.pop(context,
                            bookCover); // Return the selected book cover
                      },
                    );
                  },
                ),
              ),
            if (_books.isEmpty && _controller.text.isNotEmpty)
              const Center(child: Text('No results found.')),
          ],
        ),
      ),
    );
  }
}
