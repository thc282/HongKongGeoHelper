import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/MyHomePage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'Hong Kong Geo Helper';

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(homeTitle: 'My Home Page'),
      initialRoute: '/',
      routes: const {
        //'lamppost': (context) => const MyHomePage(title: 'Lamma Post'),
      },
    );
  }
}
