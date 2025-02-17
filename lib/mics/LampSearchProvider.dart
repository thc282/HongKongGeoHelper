import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/API_config.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:provider/provider.dart';

class LampSearchProvider extends ChangeNotifier {
  List<LamppostInfo> _searchResult = [];
  String? _searchText;
  TabController? _tabController;
  String? _errorMessage;

  List<LamppostInfo> get searchResult => _searchResult;
  String? get searchText => _searchText;
  TabController? get tabController => _tabController;
  String? get errorMessage => _errorMessage;

  Future<List<LamppostInfo>>fetchSearchResult(String text) async {
    try {
      _errorMessage = null;
      //notifyListeners();

      final (statusCode, responseBody) = await ApiService.fetchData(
        endpoint: ApiEndpoint.lamppost,
        params: {
          'Lamp_Post_Number': text.toUpperCase(),
        },
      );
      if (statusCode == 200) {
        _searchResult = parseSearchResults(responseBody);
      } else {
        _errorMessage = '查詢失敗: $statusCode';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
    return _searchResult;
  }

  List<LamppostInfo> parseSearchResults(String responseBody) {
    try {
      return [LamppostInfo.fromJson(json.decode(responseBody))];
    } catch (e) {
      _errorMessage = '數據解析錯誤: ${e.toString()}';
      return [];
    }
  }

 /*
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
  }*/

  static LampSearchProvider of(BuildContext context) {
    return Provider.of<LampSearchProvider>(context, listen: false);
  }
}
