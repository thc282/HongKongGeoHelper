import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LampSearchProvider extends ChangeNotifier {
  dynamic _searchResult;
  String? _searchText;
  TabController? _tabController;

  dynamic get searchResult => _searchResult;
  String? get searchText => _searchText;
  TabController? get tabController => _tabController;

  void updateSearchResult(dynamic result) {
    _searchResult = result;
    notifyListeners();
  }

  void updateSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void updateTabController(TabController controller) {
    _tabController = controller;
    notifyListeners();
  }

  static LampSearchProvider of(BuildContext context) {
    return Provider.of<LampSearchProvider>(context, listen: false);
  }
}