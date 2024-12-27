import 'package:flutter/material.dart';

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Welcome to Hong Kong Geo Helper',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          // Add more page content
        ],
      ),
    );
  }
}