import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../widgets/primary_button.dart';

class RoomViewPage extends StatelessWidget {
  const RoomViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, using hardcoded room data. Later this will come from arguments.
    final bool isBooked = false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Conference Room Alpha',
                          style: AppTextStyles.heading1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isBooked ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isBooked ? 'Booked' : 'Available',
                          style: AppTextStyles.caption.copyWith(
                            color: isBooked ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text('Floor 2, Library Building', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.large),
                  
                  Text('Details', style: AppTextStyles.bodyBold),
                  const SizedBox(height: AppSpacing.medium),
                  _buildDetailRow(context, Icons.people_outline_rounded, 'Capacity', '12 People'),
                  _buildDetailRow(context, Icons.videocam_outlined, 'Equipment', 'Projector, Whiteboard'),
                  _buildDetailRow(context, Icons.wifi_rounded, 'Connectivity', 'High-speed Wi-Fi'),
                  
                  const SizedBox(height: AppSpacing.large),
                  
                  if (isBooked) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Booked by: John Smith until 1:00 PM',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    PrimaryButton(
                      text: 'Reserve Now',
                      onPressed: () {
                        // Implement booking logic
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xlarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.bodyBold),
            ],
          ),
        ],
      ),
    );
  }
}
