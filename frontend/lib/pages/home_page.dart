import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../widgets/room_horizontal_card.dart';
import '../widgets/quick_access_card.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.displayName ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: AppTextStyles.body),
                      Text(userName, style: AppTextStyles.heading2),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),

              // Active Booking Card
              Text('Your Active Booking', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.small),
              _buildActiveBookingCard(context),
              const SizedBox(height: AppSpacing.large),

              // Available Rooms (Horizontal Scroll)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Rooms', style: AppTextStyles.bodyBold),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return RoomHorizontalCard(index: index);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // Quick Access
              Text('Quick Access', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.small),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickAccessCard(
                    icon: Icons.history_rounded,
                    label: 'Recent',
                    onTap: () {},
                  ),
                  QuickAccessCard(
                    icon: Icons.map_rounded,
                    label: 'Live Map',
                    onTap: () {},
                  ),
                  QuickAccessCard(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Suggestions',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Conference Room Alpha', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
              const Icon(Icons.check_circle_rounded, color: Colors.white),
            ],
          ),
          const SizedBox(height: 4),
          Text('Floor 2, Library Building', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text('Today, 10:00 AM - 11:30 AM', style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Check-in'),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                  ),
                  child: const Text('Directions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
