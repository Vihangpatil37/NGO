import 'package:flutter/material.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/new_case/new_case_screen.dart';
import '../../features/old_case/old_case_screen.dart';
import '../../features/token/token_confirmed_screen.dart';
import '../../features/token/my_token_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/doctor/doctor_login_screen.dart';
import '../../features/doctor/doctor_availability_screen.dart';
import '../../features/notifications/notification_inbox_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String welcome = '/';
  static const String newCase = '/new-case';
  static const String oldCase = '/old-case';
  static const String tokenConfirmed = '/token-confirmed';
  static const String myToken = '/my-token';
  static const String help = '/help';
  static const String doctorLogin = '/doctor-login';
  static const String doctorAvailability = '/doctor-availability';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );
      case newCase:
        return MaterialPageRoute(builder: (_) => const NewCaseScreen());
      case oldCase:
        return MaterialPageRoute(builder: (_) => const OldCaseScreen());
      case tokenConfirmed:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TokenConfirmedScreen(
            tokenNumber: args?['tokenNumber'] ?? 0,
            caseNumber: args?['caseNumber'] ?? '',
            queuePosition: args?['queuePosition'] ?? 0,
            tokenId: args?['tokenId'] ?? '',
            patientName: args?['patientName'] ?? '',
          ),
        );
      case myToken:
        final args = settings.arguments as Map<String, dynamic>?;
        final tokenId = args?['tokenId'] as String?;
        return MaterialPageRoute(
          builder: (_) => MyTokenScreen(
            tokenId: tokenId ?? '', // Should always be provided
          ),
        );
      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case doctorLogin:
        return MaterialPageRoute(builder: (_) => const DoctorLoginScreen());
      case doctorAvailability:
        return MaterialPageRoute(builder: (_) => const DoctorAvailabilityScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationInboxScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
