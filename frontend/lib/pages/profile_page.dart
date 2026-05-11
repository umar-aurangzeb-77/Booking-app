import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.large),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(user?.displayName ?? 'Student', style: AppTextStyles.heading2),
            Text(user?.email ?? 'No email', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.large),
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, '0', 'Bookings'),
                  _buildStatItem(context, '0h', 'Total Time'),
                  _buildStatItem(context, '5.0', 'Rating'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            
            _buildProfileOption(Icons.settings_rounded, 'Account Settings'),
            _buildProfileOption(Icons.notifications_rounded, 'Notification Preferences'),
            _buildProfileOption(Icons.help_outline_rounded, 'Support & Help'),
            const SizedBox(height: AppSpacing.large),
            
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.bodyBold.copyWith(fontSize: 20, color: Theme.of(context).primaryColor)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryText),
        title: Text(title, style: AppTextStyles.body),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
        tileColor: Colors.white,
      ),
    );
  }
}
