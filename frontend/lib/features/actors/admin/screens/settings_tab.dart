import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/auth_service.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  static const primaryBlue = Color(0xFF4A80F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        children: [
          _buildHeading('ACCOUNT IDENTITY'),
          _buildCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              title: const Text(
                'Admin Authority',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                'admin@campus.edu',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.verified_rounded,
                color: Colors.green,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildHeading('SYSTEM PREFERENCES'),
          _buildCard(
            child: Column(
              children: [
                _buildToggle('Push Notifications', 'Real-time alerts', true),
                const Divider(height: 1, indent: 60),
                _buildToggle('Cloud Sync', 'Automatic data backup', false),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildHeading('SYSTEM INFRASTRUCTURE'),
          _buildCard(
            child: Column(
              children: [
                _buildInfo(
                  'Version Build',
                  '2.4.0-Pro',
                  Icons.rocket_launch_rounded,
                ),
                const Divider(height: 1, indent: 60),
                _buildInfo(
                  'API Connectivity',
                  'Operational',
                  Icons.wifi_tethering_rounded,
                  status: true,
                ),
              ],
            ),
          ),
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Color(0xFF94A3B8),
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

  Widget _buildToggle(String title, String subtitle, bool val) {
    return SwitchListTile(
      value: val,
      onChanged: (v) {},
      activeColor: primaryBlue,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildInfo(
    String title,
    String value,
    IconData icon, {
    bool status = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: status ? Colors.green : const Color(0xFF1E293B),
        ),
      ),
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
