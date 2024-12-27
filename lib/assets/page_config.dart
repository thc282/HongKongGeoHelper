import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import '../page/HomePage.dart';
import '../page/LamppostPage.dart';

enum PageConfigEnum{
  home(
    title: 'Hong Kong Geo Helper',
    icon: Icons.home,
    page: [HomePage()],
    tabs: ['home']
  ),
  lamppost(
    title: '路燈查詢',
    icon: CustomIcon.lamp_street,
    page: [SearchTab(), ResultTab()],
    tabs: ['Search', 'Result']
  );
  //add others

  const PageConfigEnum({
    required this.title,
    required this.icon,
    required this.page,
    required this.tabs,
  });

  final String title;
  final IconData icon;
  final List<Widget> page;
  final List<String> tabs;
}

enum TransportDropdown{
  noSelect(value:"", label:""),
  driving(value:"driving", label:"開車"),
  walking(value:"walking", label:"走路"),
  bicycling(value:"bicycling", label:"騎單車"),
  transit(value:"transit", label:"搭乘大眾運輸");

  const TransportDropdown({required this.value, required this.label});

  final String value;
  final String label;
}