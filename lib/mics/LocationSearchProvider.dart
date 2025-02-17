import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/API_config.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:provider/provider.dart';

class LocationSearchProvider extends ChangeNotifier {
  List<LocationSearchInfo> _searchResult = [];
  String? _searchText;
  TabController? _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  List<LocationSearchInfo> get searchResult => _searchResult;
  String? get searchText => _searchText;
  TabController? get tabController => _tabController;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<List<LocationSearchInfo>> fetchSearchResult(String text) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      //notifyListeners();

      final (statusCode, responseBody) =
      await ApiService.fetchData(
        endpoint: ApiEndpoint.locationSearch,
        params: {
          'q': text,
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
      _isLoading = false;
      notifyListeners();
    }
    return _searchResult;
  }

  List<LocationSearchInfo> parseSearchResults(String responseBody) {
    try {
      final List<dynamic> jsonList = json.decode(responseBody);
      return jsonList.map((json) => LocationSearchInfo.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = '數據解析錯誤: ${e.toString()}';
      return [];
    }
  }
  
  /*void updateSearchResult(List<LocationSearchInfo> result) {
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

  static LocationSearchProvider of(BuildContext context) {
    return Provider.of<LocationSearchProvider>(context, listen: false);
  }
}