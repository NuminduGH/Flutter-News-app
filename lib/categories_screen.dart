import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';


import 'news_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'news_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<String> categoryList = [
    "general",
    "business",
    "entertainment",
    "health",
    "science",
    "sports",
    "technology",
  ];

  late String selectedCategory;
  late Map<String, Future<List<Article>>> categoryFutures;

  @override
  void initState() {
    super.initState();
    selectedCategory = categoryList.first; // Default to the first category
    categoryFutures = Map.fromIterable(
      categoryList,
      key: (category) => category,
      value: (category) => getCategoryNews(category),
    );
  }

  Future<List<Article>> getCategoryNews(String category) async {
    final apiKey = "805e9705aba14786a075ba05571f49e8";
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=us&category=$category&apiKey=$apiKey'),
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
      throw Exception('Failed to load $category news');
    }
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryList.map((category) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: selectedCategory == category ? Colors.blue : null,
              ),
              child: Text(category.toUpperCase()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryNewsListView(String category) {
    return FutureBuilder<List<Article>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print("Error loading $category news: ${snapshot.error}");
          if (snapshot.error is http.Response) {
            final http.Response response = snapshot.error as http.Response;
            print("Response body: ${response.body}");
          }
          return Center(
            child: Text("Error loading $category news: ${snapshot.error}"),
          );
        } else {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            final List<Article> categoryNews = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildNewsListView(categoryNews),
              ],
            );
          } else {
            return Center(
              child: Text("No news available for $category"),
            );
          }
        }
      },
      future: getCategoryNews(category),
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCategoryList(),
            _buildCategoryNewsListView(selectedCategory),
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

















