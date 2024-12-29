import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../assets/page_config.dart';
import '../assets/API_config.dart';

import '../gadget/buildrow.dart';


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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          //loading indicator
          _isLoading ? 
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ) : Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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
                textCapitalization: TextCapitalization.characters,
              ),
              /*const SizedBox(height: 50),
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
              ),*/
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
                  setState(() {
                    _isLoading = true;
                  });
                  try{
                    final result = await ApiService.fetchData(
                      endpoint: ApiEndpoint.lamppost,
                      params: {
                        'Lamp_Post_Number': _textControllers[0].text.toUpperCase(),
                      },
                    );
                    //write the result to the provider
                    final provider = SearchResultProvider.of(context);
                    provider.updateSearchResult(LamppostInfo.fromJson(jsonDecode(result.$2)));
                    provider.tabController?.animateTo(1);
                  } catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('搜尋時發生錯誤')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              )
              // 添加更多頁面內容
            ],
          ),
        ],
      )
      
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
          final searchResult = provider.searchResult;
          
          // Handle null or invalid search result
          if (searchResult == null) {
            return const Center(child: Text('沒有搜尋結果'));
          }

          // Now we know searchResult is not null, we can safely cast it
          final lamppostInfo = searchResult as LamppostInfo;
          if (lamppostInfo.features.isEmpty) {
            return const Center(child: Text('找不到相關資料'));
          }

          final features = lamppostInfo.features[0];
          final geometry = features.geometry;
          final properties = features.properties;

          final dateAndTime = lamppostInfo.timeStamp.split("T");
          final date = dateAndTime[0]; // "YYYY-MM-DD"
          final time = dateAndTime[1].replaceAll("Z",""); // "HH:MM:SS"
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '位置資料',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                BuildRow('數據獲取時點:', '$date\n$time'),
                BuildRow('地理座標:', '[${geometry.coordinates[0]},\n${geometry.coordinates[1]}]'),
                const SizedBox(height: 10),
                Text('位置參數',
                    style: Theme.of(context).textTheme.titleMedium
                ),
                const SizedBox(height: 10),
                BuildRow('OBJECTID:', properties.OBJECTID),
                BuildRow('港柱編號:', properties.Lamp_Post_Number),
                BuildRow('經度:', properties.Longitude),
                BuildRow('緯度:', properties.Latitude),
                BuildRow('地區:', properties.District),
                BuildRow('位置:', properties.Location),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SearchResultProvider extends ChangeNotifier {
  dynamic _searchResult;
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