import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../widgets/primary_button.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String selectedFloor = 'All';
  String selectedCapacity = 'Any';

  final List<String> floors = ['All', 'Floor 1', 'Floor 2', 'Floor 3', 'Floor 4'];
  final List<String> capacities = ['Any', '2-4', '5-10', '10-20', '20+'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Rooms', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Floor', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: floors.map((floor) => _buildFilterPill(floor, selectedFloor == floor, () {
                setState(() => selectedFloor = floor);
              })).toList(),
            ),
            const SizedBox(height: AppSpacing.large),
            Text('Capacity', style: AppTextStyles.bodyBold),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: capacities.map((cap) => _buildFilterPill(cap, selectedCapacity == cap, () {
                setState(() => selectedCapacity = cap);
              })).toList(),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Apply Filters',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.large),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : AppColors.border),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
