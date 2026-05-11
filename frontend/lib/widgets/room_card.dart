import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';

class RoomCard extends StatelessWidget {
  final String? roomName;
  final int? capacity;
  final bool isAvailable;
  final String? imageUrl;
  final VoidCallback? onReserve;

  const RoomCard({
    super.key,
    this.roomName,
    this.capacity,
    this.isAvailable = true,
    this.imageUrl,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.medium)),
                ),
                child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: isAvailable ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? 'Available' : 'Booked',
                        style: AppTextStyles.caption.copyWith(
                          color: isAvailable ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Info Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roomName ?? 'Conference Room Alpha', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 4),
                      Text('Capacity: ${capacity ?? 12} • Floor 2', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isAvailable ? onReserve ?? () {
                    Navigator.pushNamed(context, '/room-view');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Theme.of(context).primaryColor : Colors.grey[200],
                    foregroundColor: isAvailable ? Colors.white : Colors.grey[400],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                  child: const Text('Reserve'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
