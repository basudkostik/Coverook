import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookCard extends StatelessWidget {
  final String bookName;
  final String bookAuthor;
  final String bookDescription;
  final int bookCommentsNumber;
  final double bookRatings;
  final int bookRatingsNumber;
  final String bookBackcover;
  final String bookFrontcover;

  const BookCard({
    super.key,
    required this.bookName,
    required this.bookAuthor,
    required this.bookDescription,
    required this.bookCommentsNumber,
    required this.bookRatings,
    required this.bookRatingsNumber,
    required this.bookBackcover,
    required this.bookFrontcover,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFBF9E8A),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),

              // Backcover
              Container(
                height: size.height * 0.25,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  image: DecorationImage(
                    image: NetworkImage(bookBackcover),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // Frontcover (floating above Backcover)
              Transform.translate(
                offset: Offset(size.width * 0.1, -size.height * 0.13),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: size.height * 0.22,
                    width: size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: NetworkImage(bookFrontcover),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Book Details (aligned close to Frontcover)
              Transform.translate(
                offset: Offset(size.width * 0.4, -size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookName,
                      style: GoogleFonts.goudyBookletter1911(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      bookAuthor,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Ratings, Comments, Favorites (in a single row near the Frontcover)
              Transform.translate(
                offset: Offset(0, -size.height * 0.18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBanner(size,
                        icon: Icons.star, label: "$bookRatings / 5"),
                    _buildBanner(size,
                        icon: Icons.comment, label: "$bookCommentsNumber"),
                    _buildBanner(size,
                        icon: Icons.favorite, label: "$bookRatingsNumber"),
                  ],
                ),
              ),

              // Book Description (shortened and aligned closer)
              Transform.translate(
                offset: Offset(0, -size.height * 0.15),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F6E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Text(
                    bookDescription,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Ratings Section
              Transform.translate(
                offset: Offset(0, -size.height * 0.12),
                child: Container(
                  height: size.height * 0.07,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F6E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Star Rating
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < bookRatings
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              // Add Firebase rating save functionality
                              print("Rating: ${index + 1} clicked");
                            },
                          );
                        }),
                      ),
                      // Favorite Button
                      Padding(
                        padding: EdgeInsets.only(right: size.width * 0.02),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              // Add Firebase favorite save functionality
                              print("Added to Favorites");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons (aligned in a row close to Frontcover)
              Transform.translate(
                offset: Offset(0, -size.height * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconBanner(
                      size,
                      icon: Icons.book_online,
                      onPressed: () {
                        // E-book function
                        print("E-book icon pressed");
                      },
                    ),
                    _buildIconBanner(
                      size,
                      icon: Icons.headset,
                      onPressed: () {
                        // Audiobook function
                        print("Audiobook icon pressed");
                      },
                    ),
                    _buildIconBanner(
                      size,
                      icon: Icons.shopping_cart,
                      onPressed: () {
                        // Purchase function
                        print("Purchase icon pressed");
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(Size size,
      {required IconData icon, required String label}) {
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.25,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6E3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: size.width * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBanner(Size size,
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.25,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6E3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black54),
        onPressed: onPressed,
      ),
    );
  }
}
