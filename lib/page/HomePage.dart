import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage( {super.key} );

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to Hong Kong Geo Helper',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        // Add more page content
      ],
    );
  }
}