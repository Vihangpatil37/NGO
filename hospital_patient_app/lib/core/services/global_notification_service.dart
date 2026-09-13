import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import '../constants/app_constants.dart';
import '../storage/session_storage.dart';
import '../network/api_service.dart';
import 'local_notification_service.dart';

/// Global service that keeps a persistent WebSocket connection to the hospital server
/// and triggers native notifications for live broadcasts and queue alerts.
class GlobalNotificationService {
  static final GlobalNotificationService _instance = GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  socket_io.Socket? _socket;
  final LocalNotificationService _notifService = LocalNotificationService();
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> initialize({String? serverUrl}) async {
    final url = serverUrl ?? AppConstants.defaultApiUrl;
    
    if (_socket != null) {
      _socket?.disconnect();
      _socket?.dispose();
    }

    debugPrint('[GlobalNotificationService] Connecting to $url...');

    _socket = socket_io.io(
      url,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket?.onConnect((_) async {
      _isConnected = true;
      debugPrint('[GlobalNotificationService] Connected to server: $url');
      await syncRooms();
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('[GlobalNotificationService] Disconnected from server');
    });

    // 1. Admin Broadcast Announcement (N04 / Hospital Announcement)
    _socket?.on('notification:broadcast', (data) {
      debugPrint('[GlobalNotificationService] Received broadcast notification: $data');
      if (data is Map) {
        final title = data['title']?.toString() ?? '📢 Hospital Announcement';
        final body = data['body']?.toString() ?? data['message']?.toString() ?? '';
        final priority = data['priority']?.toString() ?? 'high';

        _notifService.showNotification(
          title: title,
          body: body,
          priority: priority,
        );
      }
    });

    // 2. Direct Announcement broadcast
    _socket?.on('announcement:broadcast', (data) {
      debugPrint('[GlobalNotificationService] Received announcement: $data');
      if (data is Map) {
        final title = data['title']?.toString() ?? '📢 Hospital Notice';
        final body = data['message']?.toString() ?? data['body']?.toString() ?? '';
        final priority = data['priority']?.toString() ?? 'high';

        _notifService.showNotification(
          title: title,
          body: body,
          priority: priority,
        );
      }
    });

    // 3. Personalized notification (N01, N02, N03, N05, N06)
    _socket?.on('notification:new', (data) {
      debugPrint('[GlobalNotificationService] Received personal notification: $data');
      if (data is Map) {
        final title = data['title']?.toString() ?? '🏥 Hospital Alert';
        final body = data['body']?.toString() ?? '';
        final priority = data['priority']?.toString() ?? 'high';

        _notifService.showNotification(
          title: title,
          body: body,
          priority: priority,
        );
      }
    });

    _socket?.connect();
    
    await _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('[GlobalNotificationService] User granted permission for FCM');
        
        // Get token
        final fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          debugPrint('[GlobalNotificationService] FCM Token: $fcmToken');
          await _registerTokenWithBackend(fcmToken);
        }

        // Listen for token refresh
        messaging.onTokenRefresh.listen((fcmToken) {
          _registerTokenWithBackend(fcmToken);
        }).onError((err) {
          debugPrint('[GlobalNotificationService] Error refreshing FCM token: $err');
        });

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[GlobalNotificationService] Received FCM message in foreground!');
          
          if (message.notification != null) {
            _notifService.showNotification(
              title: message.notification!.title ?? 'Hospital Alert',
              body: message.notification!.body ?? '',
              priority: 'high',
            );
          }
        });
      } else {
        debugPrint('[GlobalNotificationService] User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('[GlobalNotificationService] Error setting up FCM: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final storage = await SessionStorage.getInstance();
      final patientId = storage.getPatientId();
      
      if (patientId != null && patientId.isNotEmpty) {
        final platform = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web';
        final locale = storage.getLanguageCode(); // Fetch locale from storage
        await ApiService().registerDeviceToken(
          patientId: patientId,
          token: token,
          platform: platform,
          locale: locale,
        );
        debugPrint('[GlobalNotificationService] Registered FCM token with backend');
      }
    } catch (e) {
      debugPrint('[GlobalNotificationService] Failed to register token with backend: $e');
    }
  }

  /// Sync active patient and token IDs to join room subscriptions
  Future<void> syncRooms() async {
    if (_socket == null || !_isConnected) return;

    try {
      final storage = await SessionStorage.getInstance();
      final patientId = storage.getPatientId();
      final tokenId = storage.getActiveTokenId();

      if (patientId != null && patientId.isNotEmpty) {
        _socket?.emit('join:patient', {'patientId': patientId});
      }
      if (tokenId != null && tokenId.isNotEmpty) {
        _socket?.emit('join:token', {'tokenId': tokenId});
      }
    } catch (e) {
      debugPrint('[GlobalNotificationService] Error syncing rooms: $e');
    }
  }
}
