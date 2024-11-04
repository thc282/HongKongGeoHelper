import 'package:flutter/material.dart';

class TestingPage extends StatelessWidget{
  final String hometitle;

  const TestingPage({super.key, required this.hometitle});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(hometitle),),
      body: const Column(
        children: <Widget>[
          Text('Hello World'),
        ],
      ),
      drawer: Drawer(
        child: ListView(
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