import 'package:flutter/material.dart';

import '../assets/page_config.dart';

class AppDrawer extends StatelessWidget {
  final Function(PageEnum) onPageSelected;
  final PageEnum currentPage;

  const AppDrawer({
    super.key,
    required this.onPageSelected,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration( color: Theme.of(context).primaryColor),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  )
                ],
              )
            ),
            ...PageConfigs.configs.entries.map(
              (entry) => _buildDrawerItem(
                context,
                entry.key,
                entry.value,
              )
            )
          ],
        ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    PageEnum pageEnum,
    PageConfig pageConfig,  
  ){
    return ListTile(
      leading: Icon(pageConfig.icon),
      title: Text(pageConfig.title),
      onTap: () {
        if(pageEnum != currentPage){
          onPageSelected(pageEnum);
        }
        Navigator.pop(context);
      },
    );
  }
}