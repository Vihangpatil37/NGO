import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/token/token_provider.dart';
import 'core/localization/locale_provider.dart';
import 'features/doctor/doctor_provider.dart';
import 'features/patient_auth/auth_provider.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/global_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for Push Notifications & Auth
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize local notifications service & create channels
  await LocalNotificationService().initialize();

  // Initialize persistent global WebSocket listener for instant broadcasts & live alerts
  await GlobalNotificationService().initialize();

  final storage = await SessionStorage.getInstance();
  final fromNotification = await LocalNotificationService().didLaunchFromNotification();

  String initialRoute;
  if (fromNotification) {
    // If launched from a notification, maybe go straight there.
    // However, they might not be authenticated. Let splash handle it,
    // or just route them and let the screen fail gracefully.
    // For now we'll route to splash so we can guarantee session validity.
    initialRoute = AppRouter.splash;
  } else {
    initialRoute = AppRouter.splash;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(storage)),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: HospitalPatientApp(
        initialRoute: initialRoute,
      ),
    ),
  );
}

class HospitalPatientApp extends StatelessWidget {
  final String initialRoute;

  const HospitalPatientApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'ArogyaMitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: initialRoute,
    );
  }
}
