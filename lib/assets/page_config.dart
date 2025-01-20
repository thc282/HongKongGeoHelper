import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import 'package:hong_kong_geo_helper/page/LocationIdentityPage.dart';
import '../page/HomePage.dart';
import '../page/LamppostPage.dart';
import '../page/LocationSearchPage.dart';

enum PageConfigEnum{
  home(
    title: 'Hong Kong Geo Helper',
    icon: Icons.home,
    page: [HomePage()],
    tabs: ['home'],
    descriptions:
    {
      'main': 'Welcome to Hong Kong Geo Helper',
      'tips': 'This is an APP for you to find the geo information around your position. You can search for lampposts, traffic cameras, and more.',
    }
  ),
  lamppost(
    title: '路燈查詢',
    icon: CustomIcon.lamp_street,
    page: [LampSearchTab(), LampResultTab()],
    tabs: ['Search', 'Result'],
    descriptions: 
    {
      'inputlabel': '輸入路燈編號',
      'noresult': '沒有搜尋結果',
      'nolamppost': '沒有該路燈資料',
      'fetchError': '無法取得資料',
      'search': '搜尋',
    },
  ),
  locationSearch(
    title: '地點查詢',
    icon: Icons.map,
    page: [LocationSearchTab()],
    tabs: [''],
    descriptions: 
    {
      
    }
  ),
  locationIdentify(
    title: '地點識別',
    icon: Icons.location_on,
    page: [LocationIdentityTab()],
    tabs: [''],
    descriptions: 
    {
      
    }
  ),;
  //add others

  const PageConfigEnum({
    required this.title,
    required this.icon,
    required this.page,
    required this.tabs,
    required this.descriptions,
  });

  final String title;
  final IconData icon;
  final List<Widget> page;
  final List<String> tabs;
  final Map<String, String> descriptions;
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