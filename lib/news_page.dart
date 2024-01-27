import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



import 'home_screen.dart';
import 'bookmark_screen.dart';
import 'categories_screen.dart';
import 'newswebview.dart';

class Newspage extends StatefulWidget {
  @override
  _NewspageState createState() => _NewspageState();
}

class _NewspageState extends State<Newspage> {

  void toggleBookmark(Article article) {
    setState(() {
      if (bookmarkedArticles.contains(article)) {
        bookmarkedArticles.remove(article);
      } else {
        bookmarkedArticles.add(article);
      }
    });
  }



  late Future<List<Article>> future;
  String? searchTerm;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  late SortingCriteria currentSortingCriteria;
  List<Article> bookmarkedArticles = [];
  @override
  void initState() {
    super.initState();
    future = getNewsData();
    currentSortingCriteria = SortingCriteria.latest;
  }


  Future<List<Article>> getNewsData() async {
    // Replace with your API key
    NewsAPI newsApi = NewsAPI("805e9705aba14786a075ba05571f49e8");
    return await newsApi.getTopHeadlines(country: "us");
  }



  void sortNews(SortingCriteria criteria) {
    setState(() {
      currentSortingCriteria = criteria;
      future = getNewsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Article>>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading the news"),
                    );
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<Article> sortedArticles =
                      sortArticles(snapshot.data as List<Article>);
                      return _buildNewsListView(sortedArticles);
                    } else {
                      return const Center(
                        child: Text("No news available"),
                      );
                    }
                  }
                },
                future: future,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Article> sortArticles(List<Article> articles) {
    switch (currentSortingCriteria) {
      case SortingCriteria.latest:
        return articles..sort((a, b) => b.title.compareTo(a.title));
      case SortingCriteria.oldest:
        return articles..sort((a, b) => a.title.compareTo(b.title));
    }
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
        child: InkWell(
          onTap: () {
            if (article.url != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsWebView(url: article.url!),
                ),
              );
            } else {
              // Handle the case where article.url is null (optional)
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('News article URL is null.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
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
                    return const Icon(Icons.image_not_supported);
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
              // Add a bookmark button
              IconButton(
                icon: Icon(
                  bookmarkedArticles.contains(article)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: () => toggleBookmark(article),
              ),
              // Add a bookmark button
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'News App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Sort by Latest'),
            onTap: () {
              sortNews(SortingCriteria.latest);
              Navigator.pop(context); // Close the drawer after sorting
            },
          ),
          ListTile(
            title: Text('Sort by Oldest'),
            onTap: () {
              sortNews(SortingCriteria.oldest);
              Navigator.pop(context); // Close the drawer after sorting
            },
          ),

          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),

          ListTile(
            title: Text('Search'),
            onTap: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          ListTile(
            title: Text('Bookmark'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkScreen(bookmarkedArticles: bookmarkedArticles),
                ),
              );
            },
          ),
          //ListTile(
          //title: Text('Bookmark'),
          //onTap: () {
          // Navigator.pushNamed(context, '/bookmark');
          //},
          //),
          ListTile(
            title: Text('Categories'),
            onTap: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
        ],
      ),
    );
  }
}

enum SortingCriteria {
  latest,
  oldest,
}

class Article {
  final String title;
  final String? urlToImage;
  final Source? source;
  final String? url;
  Article({required this.title, this.urlToImage, this.source, this.url});

//Article({required this.title, this.urlToImage, this.source});
}

class Source {
  final String? name;

  Source({this.name});
}

class NewsAPI {
  final String apiKey;

  NewsAPI(this.apiKey);

  Future<List<Article>> getTopHeadlines({required String country}) async {
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=$country&apiKey=$apiKey'),
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
      throw Exception('Failed to load news');
    }
  }
}













