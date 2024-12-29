import 'package:flutter/material.dart';
import '../assets/page_config.dart';

class HomePage extends StatelessWidget {
  const HomePage( {super.key} );

  @override
  Widget build(BuildContext context){
    return _buildHomeTab(context);
  }

  Widget _buildHomeTab(context){
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            PageConfigEnum.home.descriptions[0]['main']!,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            PageConfigEnum.home.descriptions[0]['tips']!,
          ),
          // Add more page content
        ],
      ),
    );
  }
}