import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/mics/LampSearchProvider.dart';
import 'package:hong_kong_geo_helper/mics/LocationSearchProvider.dart';
import 'package:provider/provider.dart';

import 'package:hong_kong_geo_helper/assets/page_config.dart';
import 'package:hong_kong_geo_helper/gadget/drawer.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LampSearchProvider(),),
      ChangeNotifierProvider(create: (_) => LocationSearchProvider(),),
    ],
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
  State<ScaffoldScreen> createState() => _ScaffoldScreenState();
}

class _ScaffoldScreenState extends State<ScaffoldScreen> with TickerProviderStateMixin {
  PageConfigEnum _currentPage = PageConfigEnum.locationSearch;
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(
      length: _currentPage.tabs.length,
      vsync: this,
    );
    // 使用 addPostFrameCallback 確保 context 已完全初始化
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      LampSearchProvider.of(context).updateTabController(_tabController);
    });*/
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
      //LampSearchProvider.of(context).updateTabController(_tabController);
    });
  }

  //main scaffold widget
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

  //build the app bar actions (upper right corner)
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

  //build the floating action button (lower right corner)
  Widget? _buildFloatingActionButton(){
    switch(_currentPage){
      case PageConfigEnum.home:
        return FloatingActionButton(
          onPressed: (){/*add*/},
          child: const Icon(Icons.question_mark),
        );
      case PageConfigEnum.lamppost:
        return FloatingActionButton(
          onPressed: () {
        },
          child: const Icon(Icons.question_mark),
        );
      default:
        return null;
    }
  }
}