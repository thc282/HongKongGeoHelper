import 'package:flutter/material.dart';
import 'package:hong_kong_geo_helper/assets/CustomIcon.dart';
import '../page/HomePage.dart';
import '../page/LamppostPage.dart';

enum PageEnum{
  home,
  lamppost,
  settings,
  profile,
  //add others
}

class PageConfig {
  final String title;
  final IconData icon;
  final Widget page;

  PageConfig({
    required this.title,
    required this.icon,
    required this.page,
  });
}

class PageConfigs{
  static final Map<PageEnum, PageConfig> configs = {
    PageEnum.home : PageConfig(title: 'Hong Kong Geo Helper', icon: Icons.home, page: const HomePage()),
    PageEnum.lamppost : PageConfig(title: 'Lamppost', icon: CustomIcon.lamp_street, page: const LamppostPage()),
    //other pages
  };
}