import 'package:flutter/material.dart';

import '../assets/page_config.dart';
import '../gadget/drawer.dart';

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
      home: const ScaffoldScreen(),
    );
  }
}

class ScaffoldScreen extends StatefulWidget {
  const ScaffoldScreen({ super.key });

  @override
  _ScaffoldScreenState createState() => _ScaffoldScreenState();
}

class _ScaffoldScreenState extends State<ScaffoldScreen> {
  PageEnum _currentPage = PageEnum.home;

  void _onPageSelected(PageEnum page){
    setState((){
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = PageConfigs.configs[_currentPage]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentConfig.title),
        actions: _buildAppBarActions(),
      ),
      drawer: AppDrawer(
        onPageSelected: _onPageSelected,
        currentPage: _currentPage,
      ),
      body: currentConfig.page,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<Widget> _buildAppBarActions(){
    switch(_currentPage){
      case PageEnum.home:
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){ /*search*/ },
          ),
        ];
      case PageEnum.lamppost:
        return [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: (){ /*add*/ },
          ),
        ];
      default:
        return [];
    }
  }

  Widget? _buildFloatingActionButton(){
    switch(_currentPage){
      case PageEnum.home:
        return FloatingActionButton(
          onPressed: (){/*add*/},
          child: const Icon(Icons.question_mark),
        );
      case PageEnum.lamppost:
        return FloatingActionButton(
          onPressed: (){/*add*/},
          child: const Icon(Icons.arrow_circle_right),
        );
      default:
        return null;
    }
  }
}