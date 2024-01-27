
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late Future<List<Article>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFuture = Future.value([]); // Initialize with an empty list of articles
  }

  Future<List<Article>> searchNews(String query) async {
    final apiKey = "805e9705aba14786a075ba05571f49e8";
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> articles = json.decode(response.body)['articles'];
      return articles.map((article) {
        return Article(
          title: article['title'],
          urlToImage: article['urlToImage'],
          source: Source(name: article['source']['name']),
        );
      }).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void _performSearch() {
    final query = _searchController.text;
    setState(() {
      _searchFuture = searchNews(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter search query',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading search results"),
                  );
                } else {
                  final List<Article> searchResults = snapshot.data!;
                  return _buildSearchResultsList(searchResults);
                }
              },
              future: _searchFuture,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(List<Article> searchResults) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        Article article = searchResults[index];
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.network(
                    article.urlToImage ?? "",
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        article.source?.name ?? "",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Article {
  final String title;
  final String? urlToImage;
  final Source? source;

  Article({required this.title, this.urlToImage, this.source});
}

class Source {
  final String? name;

  Source({this.name});
}
