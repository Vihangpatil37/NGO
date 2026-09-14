import 'package:flutter/material.dart';
import '../../features/doctor/doctor_availability_screen.dart';
import '../../features/doctor/doctor_login_screen.dart';
import '../../features/help/help_screen.dart';
import '../../features/new_case/new_case_screen.dart';
import '../../features/notifications/notification_inbox_screen.dart';
import '../../features/old_case/old_case_screen.dart';
import '../../features/token/my_token_screen.dart';
import '../../features/token/token_confirmed_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/patient_auth/phone_login_screen.dart';
import '../../features/patient_auth/otp_verification_screen.dart';
import '../../features/patient_auth/patient_profile_screen.dart';
import '../../features/patient_home/patient_home_shell.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String roleSelection = '/role-selection';
  static const String patientLogin = '/patient/login';
  static const String patientOtp = '/patient/otp';
  static const String patientProfile = '/patient/profile';
  static const String patientHome = '/patient/home';
  
  // Existing routes
  static const String newCase = '/new-case';
  static const String oldCase = '/old-case';
  static const String tokenConfirmed = '/token-confirmed';
  static const String myToken = '/my-token';
  static const String doctorLogin = '/doctor-login';
  static const String doctorAvailability = '/doctor-availability';
  static const String notifications = '/notifications';
  static const String help = '/help';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case patientLogin:
        return MaterialPageRoute(builder: (_) => const PhoneLoginScreen());
      case patientOtp:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());
      case patientProfile:
        return MaterialPageRoute(builder: (_) => const PatientProfileScreen());
      case patientHome:
        return MaterialPageRoute(builder: (_) => const PatientHomeShell());
      case newCase:
        return MaterialPageRoute(builder: (_) => const NewCaseScreen());
      case oldCase:
        return MaterialPageRoute(builder: (_) => const OldCaseScreen());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case doctorLogin:
        return MaterialPageRoute(builder: (_) => const DoctorLoginScreen());
      case doctorAvailability:
        return MaterialPageRoute(builder: (_) => const DoctorAvailabilityScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationInboxScreen());
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
