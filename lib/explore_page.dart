import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionWithBanner("Coverook Favourites", "adminFavourites"),
                buildBookList("adminFavourites"),
                buildSectionWithBanner("Coverook Top 5", "top5"),
                buildBookList("top5"),
                buildSectionWithBanner("Coverook Upcoming Books", "upcomingBooks"),
                buildBookList("upcomingBooks"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionWithBanner(String title, String collectionName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
          const SizedBox(height: 8), // Space between title and banner
        ],
      ),
    );
  }

  Widget buildBookList(String collectionName) {
    return SizedBox(
      height: 200,
      child: StreamBuilder(
        stream: getBookStream(collectionName),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(
              height: 150,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xfff7f6e3), // Banner background color
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "No books found.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var book = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.network(
                      book['bookFrontCover'] ?? '', // Default to empty string if null
                      height: 150,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book['bookName'] ?? 'No title', // Default to 'No title' if null
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getBookStream(String collectionName) {
    if (collectionName == "adminFavourites") {
      // Get data from adminFavourites
      return FirebaseFirestore.instance
          .collection('adminFavourites')
          .snapshots();
    } else if (collectionName == "top5") {
      // Get top 10 books with the highest ratings
      return FirebaseFirestore.instance
          .collection('books')
          .orderBy('bookRatings', descending: true)
          .limit(5)
          .snapshots();
    } else if (collectionName == "upcomingBooks") {
      // Get data from upcomingBooks
      return FirebaseFirestore.instance
          .collection('upcomingBooks')
          .snapshots();
    } else {
      return FirebaseFirestore.instance.collection('books').snapshots(); // Default fallback
    }
  }
}