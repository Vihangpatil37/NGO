import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/services/global_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  StreamSubscription? _notifSubscription;

  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  dynamic get latestNotification => _notifications.isNotEmpty ? _notifications.first : null;

  NotificationProvider() {
    _notifSubscription = GlobalNotificationService().notificationStream.listen((data) {
      fetchNotifications(refreshCount: true);
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications({bool refreshCount = true}) async {
    if (_notifications.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    
    _error = null;

    try {
      final storage = await SessionStorage.getInstance();
      final patientId = storage.getPatientId();
      
      if (patientId == null || patientId.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await _apiService.getNotifications(patientId: patientId);
      var fetchedList = res['data']?['notifications'] ?? [];
      
      final clearedAtStr = storage.getNotificationsClearedAt();
      final clearedAt = clearedAtStr != null ? DateTime.parse(clearedAtStr) : null;

      if (clearedAt != null) {
        fetchedList = fetchedList.where((n) {
          if (n['createdAt'] == null) return true;
          final dt = DateTime.tryParse(n['createdAt']);
          return dt != null && dt.isAfter(clearedAt);
        }).toList();
      }
      
      _notifications = fetchedList;
      
      if (refreshCount) {
        await fetchUnreadCount(patientId: patientId);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load notifications.';
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount({String? patientId}) async {
    try {
      if (patientId == null) {
        final storage = await SessionStorage.getInstance();
        patientId = storage.getPatientId();
      }
      
      if (patientId == null || patientId.isEmpty) return;

      _unreadCount = await _apiService.getUnreadNotificationCount(patientId: patientId);
      notifyListeners();
    } catch (_) {
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      
      final index = _notifications.indexWhere((n) => n['_id'] == id);
      if (index != -1 && _notifications[index]['isRead'] != true) {
        _notifications[index]['isRead'] = true;
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (_) {
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      final storage = await SessionStorage.getInstance();
      final patientId = storage.getPatientId();
      
      await _apiService.markAllNotificationsAsRead(patientId: patientId);
      
      for (var n in _notifications) {
        n['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {
    }
  }
}
