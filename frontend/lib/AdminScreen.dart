import 'package:flutter/material.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}
class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.cyan[400],
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.cyanAccent[400],
            tabs: const [
              Tab(icon: Icon(Icons.folder)),
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon: Icon(Icons.manage_accounts)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('This is the Courses page')),
            Center(child: Text('This is the Dashboard page')),
            Center(child: Text('Here is the User Management page')),
            Center(child: Text('This is the Settings page')),
          ],
        ),
      ),
    );
  }
}