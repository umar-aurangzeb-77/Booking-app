import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';

class RoomHorizontalCard extends StatelessWidget {
  final int index;

  const RoomHorizontalCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: AppSpacing.medium, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.medium)),
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Room ${index + 1}', style: AppTextStyles.bodyBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Capacity: ${10 + index * 5}', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.success),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/room-view');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 28),
                        elevation: 0,
                      ),
                      child: const Text('Reserve', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
