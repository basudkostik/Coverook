import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;

class FavouritesWidget extends StatelessWidget {
  final String userId;

  const FavouritesWidget({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favourites',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('favourites')
                .where('userId', isEqualTo: userId) // Match userId
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final documents = snapshot.data!.docs;

              if (documents.isEmpty) {
                return const Center(child: Text('No favourites found.'));
              }

              // Use the first document for this example
              final data = documents.first.data() as Map<String, dynamic>;

              // Extract favorite URLs
              final favoriteUrls = [
                data['favori1'],
                data['favori2'],
                data['favori3'],
                data['favori4'],
                data['favori5'],
              ];

              devtools.log('Favorite URLs: $favoriteUrls');

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: favoriteUrls.map((url) {
                    if (url == null || url.isEmpty) {
                      // Show a blank widget for empty favorites
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[200], // Placeholder color
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    } else {
                      // Show the favorite image
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
