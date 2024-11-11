import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookmark.dart';

class BookmarkService {
  static const String _bookmarkKey = 'bookmarks';

  static Future<void> saveBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    bookmarks.add(json.encode(bookmark.toMap()));
    await prefs.setStringList(_bookmarkKey, bookmarks);
    print('Image Saved: ${bookmark.toMap()}');  // Debugging print
  }

  static Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    print('Loaded Bookmarks: $bookmarks');  // Debugging print
    return bookmarks.map((bookmark) => Bookmark.fromMap(json.decode(bookmark))).toList();
  }

  static Future<void> removeBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    bookmarks.removeWhere((item) => json.encode(bookmark.toMap()) == item);
    await prefs.setStringList(_bookmarkKey, bookmarks);
    print('Image unsaved: ${bookmark.toMap()}');  // Debugging print
  }
}
