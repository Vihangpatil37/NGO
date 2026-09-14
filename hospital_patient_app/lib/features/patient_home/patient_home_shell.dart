import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/patient_bottom_nav.dart';
import 'patient_home_screen.dart';
import '../notifications/notification_inbox_screen.dart';
import '../../core/storage/session_storage.dart';

class PatientHomeShell extends StatefulWidget {
  const PatientHomeShell({Key? key}) : super(key: key);

  @override
  State<PatientHomeShell> createState() => _PatientHomeShellState();
}

class _PatientHomeShellState extends State<PatientHomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PatientHomeScreen(),
    const Center(child: Text('Appointments (Coming Soon)')),
    const NotificationInboxScreen(),
    const Center(child: Text('Profile (Coming Soon)')),
  ];

  void _onTabSelected(int index) {
    // If they tap profile, just show a temporary logout for now
    if (index == 3) {
      _showProfileDialog();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profile'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final storage = await SessionStorage.getInstance();
              await storage.clearSession();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRouter.splash, (r) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
