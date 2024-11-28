import 'package:flutter/material.dart';
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
  late String selectedType;

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
          // 添加更多頁面內容
        ],
      ),
    );
  }
}