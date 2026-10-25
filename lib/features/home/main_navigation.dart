import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import 'home_screen.dart';
import '../weekly_insight/insights_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final AppDependencies dependencies;
  const MainNavigation({super.key, required this.dependencies});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // ตอนนี้ทุกหน้ารับ dependencies เรียบร้อยแล้ว เส้นแดงจะหายไปครับ
    _screens = [
      HomeScreen(dependencies: widget.dependencies),
      InsightsScreen(dependencies: widget.dependencies),
      ProfileScreen(dependencies: widget.dependencies),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF333333),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'หน้าหลัก'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), activeIcon: Icon(Icons.bar_chart), label: 'สถิติ'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}