import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/token/token_provider.dart';
import 'core/localization/locale_provider.dart';
import 'features/doctor/doctor_provider.dart';
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
  
  // Initialize Firebase for Push Notifications
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize local notifications service & create channels
  await LocalNotificationService().initialize();

  // Initialize persistent global WebSocket listener for instant broadcasts & live alerts
  await GlobalNotificationService().initialize();

  final storage = await SessionStorage.getInstance();
  final hasSession = storage.hasActiveSession();
  final activeTokenId = storage.getActiveTokenId();
  final hasDoctorSession = storage.hasDoctorSession();
  final fromNotification = await LocalNotificationService().didLaunchFromNotification();

  String initialRoute;
  if (fromNotification) {
    initialRoute = AppRouter.notifications;
  } else if (hasDoctorSession) {
    initialRoute = AppRouter.doctorAvailability;
  } else if (hasSession && activeTokenId != null) {
    initialRoute = AppRouter.myToken;
  } else {
    initialRoute = AppRouter.welcome;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(storage)),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: HospitalPatientApp(
        initialRoute: initialRoute,
        initialTokenId: activeTokenId,
      ),
    ),
  );
}

class HospitalPatientApp extends StatelessWidget {
  final String initialRoute;
  final String? initialTokenId;

  const HospitalPatientApp({
    super.key,
    required this.initialRoute,
    this.initialTokenId,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'Hospital Token App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (initialRouteName) {
        if (initialRouteName == AppRouter.myToken && initialTokenId != null) {
          return [
            AppRouter.generateRoute(
              RouteSettings(
                name: AppRouter.myToken,
                arguments: {'tokenId': initialTokenId},
              ),
            ),
          ];
        }
        return [AppRouter.generateRoute(RouteSettings(name: initialRouteName))];
      },
    );
  }
}
