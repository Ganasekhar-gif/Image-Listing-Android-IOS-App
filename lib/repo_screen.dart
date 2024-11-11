import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class RepoScreen extends StatefulWidget {
  @override
  _RepoScreenState createState() => _RepoScreenState();
}

class _RepoScreenState extends State<RepoScreen> {
  List _repos = [];
  late Dio _dio;
  final String apiUrl = 'https://api.github.com/gists/public';
  bool _isFirstLoad = true; // To check if it's the first load

  @override
  void initState() {
    super.initState();
    _initializeDio();
    _fetchRepos(); // First fetch on load
  }

  // Initialize Dio with caching
  void _initializeDio() {
    _dio = Dio();
    _dio.interceptors.add(DioCacheManager(
      CacheConfig(baseUrl: apiUrl),
    ).interceptor);
  }

  // Fetch repositories from the GitHub API with caching
  Future<void> _fetchRepos({bool refresh = false}) async {
    try {
      // If it's the first time loading, we want to wait for the data to be fetched
      final response = await _dio.get(
        apiUrl,
        options: buildCacheOptions(
          Duration(days: 7), // Cache duration
          forceRefresh: refresh, // Force refresh if requested
          options: Options(headers: {'accept': 'application/vnd.github.v3+json'}),
        ),
      );

      // Log the response to check the structure
      print('Response data: ${response.data}'); // Check the data type

      setState(() {
        _repos = response.data;
        _isFirstLoad = false; // Mark first load as completed
      });

      // If it's not the first load, fetch fresh data in the background (without blocking the UI)
      if (!_isFirstLoad) {
        _fetchRepos(refresh: true);
      }
    } catch (error) {
      print('Failed to load repos: $error');
      // Show an alert if there's an error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load repositories: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repositories')),
      body: _repos.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView.builder(
        itemCount: _repos.length,
        itemBuilder: (context, index) {
          var repo = _repos[index];
          return ListTile(
            title: Text(repo['description'] ?? 'No description'),
            subtitle: Text(
              'Comments: ${repo['comments']}, Created: ${repo['created_at']}, Updated: ${repo['updated_at']}',
            ),
            onTap: () => _openFileListingScreen(repo),
            onLongPress: () => _showOwnerInfoDialog(repo),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchRepos(refresh: true), // Refresh on button click
        child: Icon(Icons.refresh),
      ),
    );
  }

  // Show owner info in a dialog when long pressing on a repo
  void _showOwnerInfoDialog(Map repo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Owner Info'),
        content: Text('Owner: ${repo['owner']['login'] ?? 'Unknown'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Navigate to the file listing screen for the selected repo
  void _openFileListingScreen(Map repo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileListingScreen(files: repo['files']),
      ),
    );
  }
}

class FileListingScreen extends StatelessWidget {
  final Map files;

  FileListingScreen({required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Files")),
      body: ListView(
        children: files.keys.map<Widget>((fileName) {
          var file = files[fileName];
          return ListTile(
            title: Text(fileName),
            subtitle: Text('Type: ${file['type']}'),
            onTap: () {
              // Add logic to open file content or link to GitHub
            },
          );
        }).toList(),
      ),
    );
  }
}
