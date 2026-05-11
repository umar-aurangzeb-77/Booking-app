import 'package:flutter/material.dart';

class FacilitySelector extends StatelessWidget {
  final List<String> selectedFacilities;
  final Function(String) onToggle;

  const FacilitySelector({
    super.key,
    required this.selectedFacilities,
    required this.onToggle,
  });

  final Map<String, IconData> availableFacilities = const {
    'Internet / WiFi': Icons.wifi,
    'Smart Board': Icons.developer_board,
    'Air Cooling / AC': Icons.ac_unit,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: availableFacilities.keys.map((facility) {
        final isSelected = selectedFacilities.contains(facility);
        return FilterChip(
          label: Text(facility),
          selected: isSelected,
          onSelected: (_) => onToggle(facility),
          avatar: Icon(
            availableFacilities[facility],
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            size: 18,
          ),
          selectedColor: Theme.of(context).primaryColor,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        );
      }).toList(),
    );
  }
}
