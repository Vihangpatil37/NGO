import 'package:flutter/material.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/new_case/new_case_screen.dart';
import '../../features/old_case/old_case_screen.dart';
import '../../features/token/token_confirmed_screen.dart';
import '../../features/token/my_token_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/doctor/doctor_login_screen.dart';
import '../../features/doctor/doctor_availability_screen.dart';

class AppRouter {
  static const String welcome = '/';
  static const String newCase = '/new-case';
  static const String oldCase = '/old-case';
  static const String tokenConfirmed = '/token-confirmed';
  static const String myToken = '/my-token';
  static const String help = '/help';
  static const String doctorLogin = '/doctor-login';
  static const String doctorAvailability = '/doctor-availability';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return _buildRoute(const WelcomeScreen(), settings);
      case newCase:
        return _buildRoute(const NewCaseScreen(), settings);
      case oldCase:
        return _buildRoute(const OldCaseScreen(), settings);
      case tokenConfirmed:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          TokenConfirmedScreen(
            tokenNumber: args?['tokenNumber'] ?? 0,
            caseNumber: args?['caseNumber'] ?? '',
            queuePosition: args?['queuePosition'] ?? 0,
            tokenId: args?['tokenId'] ?? '',
            patientName: args?['patientName'] ?? '',
          ),
          settings,
        );
      case myToken:
        final args = settings.arguments as Map<String, dynamic>?;
        final tokenId = args?['tokenId'] as String?;
        return _buildRoute(
          MyTokenScreen(
            tokenId: tokenId ?? '',
          ),
          settings,
        );
      case help:
        return _buildRoute(const HelpScreen(), settings);
      case doctorLogin:
        return _buildRoute(const DoctorLoginScreen(), settings);
      case doctorAvailability:
        return _buildRoute(const DoctorAvailabilityScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
