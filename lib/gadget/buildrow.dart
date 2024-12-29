import 'package:flutter/material.dart';

class BuildRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const BuildRow(
    this.label,
    this.value, 
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
  }
}