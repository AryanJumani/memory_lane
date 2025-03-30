import 'package:flutter/material.dart';
import 'package:trial_flutter/screens/widgets/filter.dart';
import 'package:trial_flutter/screens/widgets/photo.dart';
import 'widgets/display_photo.dart';
import 'widgets/profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int ind = 0;

  final List<Widget> _pages = [
    DisplayPhoto(),
    FilterScreen(),
    CameraScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[ind],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: ind,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        onTap: (index) {
          setState(() {
            ind = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter),
            label: "Filter",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Upload photo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          )
        ],
      ),
    );
  }
}
