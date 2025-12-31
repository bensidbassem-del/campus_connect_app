import 'package:flutter/material.dart';

import 'features/authentication/widgets/auth_gate.dart';

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // automatically navigates based on role
    );
  }
}
