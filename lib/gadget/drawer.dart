import 'package:flutter/material.dart';

import '../assets/page_config.dart';

class AppDrawer extends StatelessWidget {
  final Function(PageConfigEnum) onPageSelected;
  final PageConfigEnum currentPage;

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
            ...PageConfigEnum.values.map(
              (entry) => _buildDrawerItem(
                context,
                entry,
              )
            )
          ],
        ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    PageConfigEnum page,
  ){
    return ListTile(
      leading: Icon(page.icon),
      title: Text(page.title),
      onTap: () {
        if(page != currentPage){
          onPageSelected(page);
        }
        Navigator.pop(context);
      },
    );
  }
}