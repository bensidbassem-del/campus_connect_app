import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/auth_service.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('New Student Notifications'),
          subtitle: const Text('Alert when students register'),
          activeColor: primaryBlue,
          value: true,
          onChanged: (val) {},
        ),
        const Divider(),
        const SizedBox(height: 32),

        const Text(
          'Account Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout_outlined, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () => ref.read(authServiceProvider).logout(),
        ),
        const Divider(),
        const SizedBox(height: 32),

        const Text(
          'System Info',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Version'),
          trailing: Text(
            '1.0.0 (Production)',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('API Status'),
          trailing: Text('Connected', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
