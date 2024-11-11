import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bookmark_service.dart';
import 'bookmark.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List _images = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _errorMessage = '';
  int _page = 1;  // Start with page 1
  final int _perPage = 30;  // Number of images per page

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_scrollListener);
  }

  // Scroll listener to fetch more images when reaching the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore) {
      _fetchImages();  // Fetch more images when the user scrolls to the bottom
    }
  }

  Future<void> _fetchImages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use page and per_page parameters for pagination
      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/photos?page=$_page&per_page=$_perPage&client_id=aZ_j0Keilgq7B0aR4XmkN0ULivMvYXkoKt-oweECLkw',
        ),
      );

      if (response.statusCode == 200) {
        List fetchedImages = json.decode(response.body);

        // Check if more images are available
        setState(() {
          _images.addAll(fetchedImages);
          _isLoading = false;
          if (fetchedImages.length < _perPage) {
            _hasMore = false;  // No more images to load
          }
          _page++;  // Increment page number for next request
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load images. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading images: $e';
        _isLoading = false;
      });
    }
  }

  // Open image in full screen with bookmarking functionality
  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: _images[index]['urls']['regular'],
          title: _images[index]['alt_description'] ?? 'No Title',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _images.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchImages, // Retry loading images
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          var image = _images[index];
          return GestureDetector(
            onTap: () => _openFullScreenImage(index),
            child: CachedNetworkImage(
              imageUrl: image['urls']['regular'],
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      );
    }
  }
}

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

  Future<void> _checkIfBookmarked() async {
    List<Bookmark> bookmarks = await BookmarkService.getBookmarks();
    setState(() {
      _isBookmarked = bookmarks.any((bookmark) => bookmark.imageUrl == widget.imageUrl);
    });
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
            onPressed: () async {
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
            },
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
