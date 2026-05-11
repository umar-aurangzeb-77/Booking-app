import 'package:flutter/material.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}
