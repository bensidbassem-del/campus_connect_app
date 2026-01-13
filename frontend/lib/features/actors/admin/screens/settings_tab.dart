import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_providers.dart';
import '../../../../shared/services/auth_service.dart';
import 'admin_style.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  static const primaryBlue = Color(
    0xFF4A80F0,
  ); // Consider replacing with AdminStyle.primary

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(adminSettingsProvider);
    final settingsNotifier = ref.read(adminSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        children: [
          _buildHeading('Account Identity'),
          _buildCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminStyle.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AdminStyle.primary,
                  size: 22,
                ),
              ),
              title: Text(
                'Admin Authority',
                style: AdminStyle.subHeader.copyWith(fontSize: 15),
              ),
              subtitle: Text(
                'admin@campus.edu',
                style: AdminStyle.body.copyWith(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildHeading('System Preferences'),
          _buildCard(
            child: Column(
              children: [
                _buildToggle(
                  'Push Notifications',
                  'Real-time alerts',
                  settings.pushNotifications,
                  (v) => settingsNotifier.togglePushNotifications(),
                ),
                const Divider(height: 1, indent: 60),
                _buildToggle(
                  'Cloud Sync',
                  'Automatic data backup',
                  settings.cloudSync,
                  (v) => settingsNotifier.toggleCloudSync(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'New Student Notifications',
              style: AdminStyle.subHeader.copyWith(fontSize: 15),
            ),
            subtitle: Text(
              'Alert when students register',
              style: AdminStyle.body.copyWith(fontSize: 12),
            ),
            activeColor: AdminStyle.primary,
            value: settings.newStudentAlerts,
            onChanged: (val) => settingsNotifier.toggleNewStudentAlerts(),
          ),
          const Divider(),
          const Divider(),
          const SizedBox(height: 48),

          _buildActionCard(
            'Secure Sign Out',
            'Disconnect current session',
            Icons.power_settings_new_rounded,
            Colors.red[400]!,
            () => ref.read(authServiceProvider).logout(),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: AdminStyle.subHeader.copyWith(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool val,
    Function(bool)? onChanged,
  ) {
    return SwitchListTile(
      value: val,
      onChanged: onChanged,
      activeThumbColor: primaryBlue,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withAlpha(26)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withAlpha(178), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
