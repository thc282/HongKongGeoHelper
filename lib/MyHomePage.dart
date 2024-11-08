import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/CustomIcon.dart';

class MyHomePage extends StatelessWidget{
  final String homeTitle;

  const MyHomePage({super.key, required this.homeTitle});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(homeTitle),),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Hello World'),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
      ),
      )
    );
  }
}