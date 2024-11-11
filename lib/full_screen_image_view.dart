import 'package:flutter/material.dart';
import 'bookmark_service.dart';
import 'bookmark.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final String title;

  FullScreenImageView({required this.imageUrl, required this.title});

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  // Check if the image is already bookmarked
  Future<void> _checkIfBookmarked() async {
    List<Bookmark> bookmarks = await BookmarkService.getBookmarks();
    setState(() {
      _isBookmarked = bookmarks.any((bookmark) => bookmark.imageUrl == widget.imageUrl);
    });
  }

  // Handle the bookmark toggle (add/remove)
  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      // Remove bookmark
      await BookmarkService.removeBookmark(Bookmark(imageUrl: widget.imageUrl, title: widget.title));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bookmark removed')),
      );
    } else {
      // Add bookmark
      Bookmark bookmark = Bookmark(imageUrl: widget.imageUrl, title: widget.title);
      await BookmarkService.saveBookmark(bookmark);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image bookmarked')),
      );
    }

    // Refresh the UI after bookmarking/unbookmarking
    _checkIfBookmarked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark, // Toggle bookmark on press
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: EdgeInsets.all(10),
          minScale: 0.1,
          maxScale: 2.0,
          child: Image.network(widget.imageUrl),
        ),
      ),
    );
  }
}
