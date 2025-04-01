import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:smartcampusadmin/users/userspage.dart';
import 'package:smartcampusadmin/banner/banner_page.dart';
import 'package:smartcampusadmin/analytics/analytics_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutPage(),
    );
  }
}

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const BannerPage(),
    const AnalyticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SmartCampus",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: SignOutButton(),
            ),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Navigation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(Icons.people, "Users", 0),
                      _buildNavItem(Icons.image, "Banners", 1),
                      _buildNavItem(Icons.analytics, "Analytics", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
              ),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Colors.blueAccent : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.blueAccent : Colors.white70,
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () => _onItemTapped(index),
      hoverColor: Colors.blueGrey[700],
    );
  }
}
