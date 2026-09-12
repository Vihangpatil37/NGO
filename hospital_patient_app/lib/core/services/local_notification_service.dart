import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../navigation/app_router.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channels for Android
  static const String highChannelId = 'arogya_high_alerts';
  static const String highChannelName = 'ArogyaMitra Priority Alerts';
  static const String highChannelDesc = 'Urgent alerts for Token Calls and OPD Queue warnings';

  static const String normalChannelId = 'arogya_normal_alerts';
  static const String normalChannelName = 'ArogyaMitra General Notices';
  static const String normalChannelDesc = 'Registration confirmation and hospital updates';

  /// Initialize Local Notification Plugin and Channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('[LocalNotification] Clicked: ${details.payload}');
        AppRouter.navigatorKey.currentState?.pushNamed(AppRouter.notifications);
      },
    );

    // Check if app was launched via notification click
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.navigatorKey.currentState?.pushNamed(AppRouter.notifications);
      });
    }

    // Create Android Notification Channels
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          highChannelId,
          highChannelName,
          description: highChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          normalChannelId,
          normalChannelName,
          description: normalChannelDesc,
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;
    debugPrint('[LocalNotification] Service initialized successfully');
  }

  /// Check if the app was launched by tapping on a notification
  Future<bool> didLaunchFromNotification() async {
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return launchDetails?.didNotificationLaunchApp ?? false;
  }

  /// Request Notification Permissions from OS and prompt user if needed
  Future<bool> requestPermission({BuildContext? context}) async {
    try {
      // 1. Check current status
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }

      // 2. Show explainer dialog if context is available
      if (context != null && context.mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: Color(0xFF0D47A1), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: const Text(
              'ArogyaMitra needs notification permission to alert you when your OPD token is called or your turn is approaching, so you never miss your consultation.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Later', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Allow Notifications'),
              ),
            ],
          ),
        );

        if (proceed != true) {
          return false;
        }
      }

      // 3. Request system permission
      final result = await Permission.notification.request();

      // Also trigger Android plugin specific permission request for Android 13+
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      debugPrint('[LocalNotification] Permission request result: $result');
      if (result.isGranted) {
        // Trigger verification notification
        await showNotification(
          title: '🏥 ArogyaMitra Alerts Active',
          body: 'Real-time OPD alerts, token calls, and hospital notices are enabled on your device.',
          priority: 'high',
        );
      }
      return result.isGranted;
    } catch (e) {
      debugPrint('[LocalNotification] Error requesting permission: $e');
      return false;
    }
  }

  /// Display a local push notification immediately on the device
  Future<void> showNotification({
    required String title,
    required String body,
    String priority = 'normal',
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final isUrgent = priority == 'urgent' || priority == 'high';
    final channelId = isUrgent ? highChannelId : normalChannelId;
    final channelName = isUrgent ? highChannelName : normalChannelName;
    final channelDesc = isUrgent ? highChannelDesc : normalChannelDesc;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: isUrgent ? Importance.max : Importance.defaultImportance,
      priority: isUrgent ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: isUrgent ? 'ArogyaMitra Alert' : 'ArogyaMitra',
      ),
    );

    final notifDetails = NotificationDetails(android: androidDetails);
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notifDetails,
      payload: payload,
    );
  }

  /// Cancel and dismiss all active notifications from status bar
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
