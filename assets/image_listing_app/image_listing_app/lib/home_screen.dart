import 'package:flutter/material.dart';
import 'repo_screen.dart';
import 'gallery_screen.dart';
import 'bookmark_screen.dart';
import 'bookmark.dart';
import 'bookmark_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Bookmark> bookmarkedImages = [];

  final List<Widget> _tabs = [
    RepoScreen(),
    GalleryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    List<Bookmark> bookmarks = await BookmarkService.getBookmarks();
    setState(() {
      bookmarkedImages = bookmarks;
    });
  }

  void _onBookmarkToggle(Bookmark bookmark) async {
    if (bookmarkedImages.contains(bookmark)) {
      await BookmarkService.removeBookmark(bookmark);
    } else {
      await BookmarkService.saveBookmark(bookmark);
    }
    _loadBookmarks();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkScreen(),
                ),
              );
              // Refresh the bookmark list after returning from BookmarkScreen
              _loadBookmarks();
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Repo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Gallery',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
