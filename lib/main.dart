import 'package:flutter/material.dart';


import 'news_page.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'bookmark_screen.dart';
import 'categories_screen.dart';


void main() {
  runApp(MyApp(),

  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    initialRoute: '/',
    routes: {
      '/': (context) => Newspage(),
      '/home': (context) => HomeScreen(),
      '/search': (context) => SearchScreen(),
      '/bookmarks': (context) => BookmarkScreen(bookmarkedArticles: []),

      '/categories': (context) => CategoriesScreen(),
    },

    );
  }
}



