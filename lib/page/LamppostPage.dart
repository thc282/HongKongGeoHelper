import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../assets/page_config.dart';
import '../assets/API_config.dart';


// LamppostPage Container
/*class LamppostPage extends StatefulWidget {
  const LamppostPage({super.key});

  @override
  State<LamppostPage> createState() => _LamppostPageState();
}

class _LamppostPageState extends State<LamppostPage> {
  dynamic searchResult;

  void _handleSearchResult(dynamic result) {
    setState(() {
      searchResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    /*return TabBarView(
      children: [
        SearchTab(onSearchResult: _handleSearchResult),
        ResultTab(searchResult: searchResult),
      ],
    );*/
  }
}*/

// SearchTab
class SearchTab extends StatefulWidget {
  const SearchTab({
    super.key,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final List<TextEditingController> _textControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String selectedType = "noSelect";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '路燈編號',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
              labelText: '輸入路燈編號',
            ),
            controller: _textControllers[0],
          ),
          const SizedBox(height: 50),
          Text(
            '交通方式',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          DropdownMenu<TransportDropdown>(
            initialSelection: TransportDropdown.noSelect,
            width: double.infinity,
            requestFocusOnTap: false,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
            ),
            controller: _textControllers[1],
            label: const Text("選擇交通方式"),
            onSelected: (TransportDropdown? transport){
              setState(() {
                selectedType = transport!.value;
              });
            },
            dropdownMenuEntries: [...TransportDropdown.values.map(
              (transport) => 
                DropdownMenuEntry<TransportDropdown>(
                  value: transport,
                  label: transport.label,
                )
            )],
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            child: Text("Go search"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            onPressed: () async{
              try{
                final result = await ApiService.fetchData(
                  endpoint: ApiEndpoint.lamppost,
                  params: {
                    'Lamp_Post_Number': _textControllers[0].text,
                  },
                );
                final provider = SearchResultProvider.of(context);
                provider.updateSearchResult(LamppostInfo.fromJson(jsonDecode(result.$2)));
                provider.tabController?.animateTo(1);
                print(jsonDecode(result.$2));
              } catch(e){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('搜尋時發生錯誤: ${e.toString()}')),
                );
                print(e);
              }
            }
          )
          // 添加更多頁面內容
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

// ResultTab
class ResultTab extends StatelessWidget {
  const ResultTab({super.key,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<SearchResultProvider>(
        builder: (context, provider, child) {
          final searchResult = provider.searchResult as LamppostInfo;
          //feature is list of lamppost info
          final features = searchResult.features[0];
          final geometry = features.geometry;
          final properties = features.properties;

          final dateAndTime = searchResult.timeStamp.split("T");
          final date = dateAndTime[0]; // "YYYY-MM-DD"
          final time = dateAndTime[1].replaceAll("Z",""); // "HH:MM:SS"
          
          return searchResult == null
              ? const Center(child: Text('沒有搜尋結果'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '位置資料',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('數據獲取時點:', '$date\n$time'),
                      _buildInfoRow('地理座標:', '[${geometry.coordinates[0]},\n${geometry.coordinates[1]}]'),
                      const SizedBox(height: 10),
                      Text('位置參數',
                          style: Theme.of(context).textTheme.titleMedium
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('OBJECTID:', properties.OBJECTID),
                      _buildInfoRow('港柱編號:', properties.Lamp_Post_Number),
                      _buildInfoRow('經度:', properties.Longitude),
                      _buildInfoRow('緯度:', properties.Latitude),
                      _buildInfoRow('地區:', properties.District),
                      _buildInfoRow('位置:', properties.Location),
                    ],
                  ),
               );
        },
      ),
    );
  }
}

Widget _buildInfoRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}

class SearchResultProvider extends ChangeNotifier {
  dynamic _searchResult = "No search results yet";
  TabController? _tabController;

  dynamic get searchResult => _searchResult;
  TabController? get tabController => _tabController;

  void updateSearchResult(dynamic result) {
    _searchResult = result;
    notifyListeners();
  }

  void updateTabController(TabController controller) {
    _tabController = controller;
    notifyListeners();
  }

  static SearchResultProvider of(BuildContext context) {
    return Provider.of<SearchResultProvider>(context, listen: false);
  }
}