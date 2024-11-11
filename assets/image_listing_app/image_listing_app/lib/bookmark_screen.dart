import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'bookmark.dart';
import 'bookmark_service.dart';
import 'full_screen_image_view.dart'; // Import FullScreenImageView

class BookmarkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: FutureBuilder<List<Bookmark>>(
        future: BookmarkService.getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading bookmarks'));
          }
          List<Bookmark> bookmarks = snapshot.data ?? [];
          return bookmarks.isEmpty
              ? Center(
            child: Text(
              'No bookmarks yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: MasonryGridView.builder(
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: bookmarks.length,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              itemBuilder: (BuildContext context, int index) {
                Bookmark bookmark = bookmarks[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to FullScreenImageView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: bookmark.imageUrl,
                          title: bookmark.title,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        bookmark.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
