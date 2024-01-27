import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> future;

  @override
  void initState() {
    super.initState();
    future = getTopNews();
  }

  Future<List<Article>> getTopNews() async {
    // Replace with your API key
    final apiKey = "805e9705aba14786a075ba05571f49e8";
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey'),
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
      throw Exception('Failed to load top news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top News'),
      ),
      body: FutureBuilder<List<Article>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading top news"),
            );
          } else {
            final List<Article> topNews = snapshot.data!;
            return _buildNewsListView(topNews);
          }
        },
        future: future,
      ),
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Article article = articleList[index];
        return _buildNewsItem(article);
      },
      itemCount: articleList.length,
    );
  }

  Widget _buildNewsItem(Article article) {
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

