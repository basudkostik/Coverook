import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PanelMenu extends StatefulWidget {
  const PanelMenu({super.key});

  @override
  _PanelMenuState createState() => _PanelMenuState();
}

class _PanelMenuState extends State<PanelMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Kullanıcıları listele
  Future<List<Map<String, dynamic>>> _getUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .where((user) =>
    _searchQuery.isEmpty ||
        (user['name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Kitapları listele
  Future<List<Map<String, dynamic>>> _getBooks() async {
    final querySnapshot = await _firestore.collection('books').get();
    return querySnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .where((book) =>
    _searchQuery.isEmpty ||
        (book['bookName'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Kullanıcı ekle veya düzenle
  Future<void> _addOrEditUser([Map<String, dynamic>? user]) async {
    final userParams = {
      'accountCreationTime': user?['accountCreationTime'] ?? '',
      'booksCount': user?['booksCount'] ?? '',
      'email': user?['email'] ?? '',
      'followerCount': user?['followerCount'] ?? '',
      'followingCount': user?['followingCount'] ?? '',
      'isEmailVerified': user?['isEmailVerified'] ?? '',
      'isSeller': user?['isSeller'] ?? '',
      'likesCount': user?['likesCount'] ?? '',
      'name': user?['name'] ?? '',
      'photoUrl': user?['photoUrl'] ?? '',
      'userId': user?['userId'] ?? '',
      'userName': user?['userName'] ?? '',
    };

    final updatedUser = await _showEditDialog(userParams, 'User Details');
    if (updatedUser != null) {
      if (user != null) {
        await _firestore.collection('users').doc(user['id']).update(updatedUser);
      } else {
        await _firestore.collection('users').add(updatedUser);
      }
      setState(() {});
    }
  }

  // Kitap ekle veya düzenle
  Future<void> _addOrEditBook([Map<String, dynamic>? book]) async {
    final bookParams = {
      'bookAuthor': book?['bookAuthor'] ?? '',
      'bookBackCover': book?['bookBackCover'] ?? '',
      'bookCommentsNumber': book?['bookCommentsNumber'] ?? '',
      'bookDescription': book?['bookDescription'] ?? '',
      'bookFrontCover': book?['bookFrontCover'] ?? '',
      'bookName': book?['bookName'] ?? '',
      'bookRatings': book?['bookRatings'] ?? '',
      'bookRatingsNumber': book?['bookRatingsNumber'] ?? '',
    };

    final updatedBook = await _showEditDialog(bookParams, 'Book Details');
    if (updatedBook != null) {
      if (book != null) {
        await _firestore.collection('books').doc(book['id']).update(updatedBook);
      } else {
        await _firestore.collection('books').add(updatedBook);
      }
      setState(() {});
    }
  }

  // Silme işlemi
  Future<void> _deleteItem(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted successfully')),
    );
  }

  // Edit dialog
  Future<Map<String, dynamic>?> _showEditDialog(
      Map<String, dynamic> params, String title) async {
    final controllers = params.map((key, value) =>
        MapEntry(key, TextEditingController(text: value?.toString() ?? '')));

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: controllers.entries.map((entry) {
                return TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: entry.key),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedData = controllers.map(
                        (key, controller) => MapEntry(key, controller.text.trim()));
                Navigator.pop(context, updatedData);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? FutureBuilder<List<Map<String, dynamic>>>(
              future: _getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error fetching users');
                } else {
                  final users = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text(user['email'] ?? 'No email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () => _addOrEditUser(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _deleteItem(
                                  'users', user['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            )
                : FutureBuilder<List<Map<String, dynamic>>>(
              future: _getBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error fetching books');
                } else {
                  final books = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return ListTile(
                        title: Text(book['bookName'] ?? 'No title'),
                        subtitle:
                        Text(book['bookAuthor'] ?? 'Unknown author'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () => _addOrEditBook(book),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _deleteItem('books', book['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
        onPressed: () {
          if (_selectedIndex == 0) {
            _addOrEditUser();
          } else {
            _addOrEditBook();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _searchController.clear();
            _searchQuery = "";
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
        ],
      ),
    );
  }
}
