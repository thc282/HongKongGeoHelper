import 'package:flutter/material.dart';

class LamppostPage extends StatelessWidget {
  const LamppostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          // 添加更多頁面內容
        ],
      ),
    );
  }
}