import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/api2model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../assets/page_config.dart';

class LamppostPage extends StatefulWidget {
  const LamppostPage({super.key});

  @override
  State<LamppostPage> createState() => _LamppostPageState();
}

class _LamppostPageState extends State<LamppostPage> {
  final List<TextEditingController> _textControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String selectedType = "noSelect";
  static const String API_URL = "https://api.csdi.gov.hk/apim/dataquery/api/?id=hyd_rcd_1629267205229_84645&layer=lamppost&limit=10&offset=0&Lamp_Post_Number=";
  late Future<LamppostInfo> futureLamppostInfo;
  //call api
  Future<LamppostInfo> fetchLamppostInfo() async {
    final res = await http.get(Uri.parse(API_URL + _textControllers[0].text));

    if(res.statusCode == 200){
      return LamppostInfo.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load lamppost info');
    }
  }

  @override
  Widget build(BuildContext context) {

    @override
    void dispose(){
      _textControllers.map((c) => c.dispose());
      super.dispose();
    }

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
                final result = await fetchLamppostInfo();
                print(result);
              } catch(e){
                print(e);
              }
            }
          )
          // 添加更多頁面內容
        ],
      ),
    );
  }
}