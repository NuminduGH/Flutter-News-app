import 'package:flutter/material.dart';

import 'news_page.dart';

import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  final List<Article> bookmarkedArticles;

  BookmarkScreen({required this.bookmarkedArticles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: bookmarkedArticles.isNotEmpty
                  ? _buildNewsListView(bookmarkedArticles)
                  : Center(
                child: Text("No bookmarked articles"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsListView(List<Article> articles) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Article article = articles[index];
        return _buildNewsItem(article);
      },
      itemCount: articles.length,
    );
  }

  Widget _buildNewsItem(Article article) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Image.network(
                article.urlToImage ?? "",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(
              article.title ?? "",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(article.source?.name ?? ""),
          ],
        ),
      ),
    );
  }
}



