import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/page/LamppostPage.dart';
import 'package:provider/provider.dart';

import '../assets/page_config.dart';
import '../gadget/drawer.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => SearchResultProvider(),
    child: const MyApp(),
  )
);

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

class _ScaffoldScreenState extends State<ScaffoldScreen> with TickerProviderStateMixin {
  PageConfigEnum _currentPage = PageConfigEnum.lamppost;
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(
      length: _currentPage.tabs.length,
      vsync: this,
    );
    // 使用 addPostFrameCallback 確保 context 已完全初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SearchResultProvider.of(context).updateTabController(_tabController);
    });
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  void _onPageSelected(PageConfigEnum page){
    setState((){
      _currentPage = page;
      _tabController.dispose();
      _tabController = TabController(
        length: _currentPage.tabs.length,
        vsync: this,
      );
      SearchResultProvider.of(context).updateTabController(_tabController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage.title),
        actions: _buildAppBarActions(),
        bottom: TabBar(
          controller: _tabController,
          tabs: _currentPage.tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      drawer: AppDrawer(
        onPageSelected: _onPageSelected,
        currentPage: _currentPage,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [..._currentPage.page],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  //build the app bar actions
  List<Widget> _buildAppBarActions(){
    switch(_currentPage){
      case PageConfigEnum.home:
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){ /*search*/ },
          ),
        ];
      case PageConfigEnum.lamppost:
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

  //build the floating action button
  Widget? _buildFloatingActionButton(){
    switch(_currentPage){
      case PageConfigEnum.home:
        return FloatingActionButton(
          onPressed: (){/*add*/},
          child: const Icon(Icons.question_mark),
        );
      case PageConfigEnum.lamppost:
        return FloatingActionButton(
          onPressed: (){/*add*/},
          child: const Icon(Icons.arrow_circle_right),
        );
      default:
        return null;
    }
  }
}