import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../assets/page_config.dart';
import '../assets/API_config.dart';


// LamppostPage Container
class LamppostPage extends StatefulWidget {
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
}

// SearchTab
class SearchTab extends StatefulWidget {
  //final Function(dynamic) onSearchResult;
  
  const SearchTab({
    super.key,
    //required this.onSearchResult,
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
                SearchResultProvider.of(context).updateSearchResult(result.$2);
                //TabController _tabController = DefaultTabController.of(context);
                //_tabController.animateTo(1);
                print(result.$2);
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
          final searchResult = provider.searchResult;
          return searchResult == null
              ? const Center(child: Text('沒有搜尋結果'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '搜尋結果',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      Text(searchResult.toString()),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class SearchResultProvider extends ChangeNotifier {
  dynamic _searchResult = "No search results yet";

  dynamic get searchResult => _searchResult;

  void updateSearchResult(dynamic result) {
    _searchResult = result;
    notifyListeners();
  }

  static SearchResultProvider of(BuildContext context) {
    return Provider.of<SearchResultProvider>(context, listen: false);
  }
}