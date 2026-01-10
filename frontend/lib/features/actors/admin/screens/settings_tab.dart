import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notificationsEnabled = true;
  bool _autoApproveEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800],
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text(
                    'Receive notifications for new registrations',
                  ),
                  activeThumbColor: Colors.cyan,
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                SwitchListTile(
                  title: const Text('Auto-approve Registrations'),
                  subtitle: const Text(
                    'Automatically approve student registrations',
                  ),
                  activeThumbColor: Colors.cyan,
                  value: _autoApproveEnabled,
                  onChanged: (value) =>
                      setState(() => _autoApproveEnabled = value),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.backup, color: Colors.cyan[700]),
                  title: const Text('Backup Database'),
                  subtitle: const Text('Create a backup of all system data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _backupDatabase(),
                ),
                ListTile(
                  leading: Icon(Icons.restore, color: Colors.cyan[700]),
                  title: const Text('Restore Defaults'),
                  subtitle: const Text('Reset all settings to default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _restoreDefaults(),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () => _logout(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800],
                  ),
                ),
                const SizedBox(height: 16),
                const ListTile(
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  title: const Text('Last Backup'),
                  subtitle: const Text('2024-01-15 14:30'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                    ),
                    onPressed: () => _checkUpdates(),
                    child: const Text(
                      'Check Updates',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _backupDatabase() {
    // TODO: Backend - POST /api/admin/backup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Database backup initiated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _restoreDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              // TODO: Backend - Reset settings
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // TODO: Backend - Logout admin
    // Clear tokens and navigate to login
  }

  void _checkUpdates() {
    // TODO: Backend - Check for app updates
  }
}
