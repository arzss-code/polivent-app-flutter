import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(child: Text('Menu')),
            ListTile(title: const Text('Dashboard'), onTap: () {}),
            ListTile(title: const Text('Users'), onTap: () {}),
            ListTile(title: const Text('Events'), onTap: () {}),
            ListTile(title: const Text('Reports'), onTap: () {}),
            ListTile(title: const Text('Settings'), onTap: () {}),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to the Admin Dashboard!'),
      ),
    );
  }
}
