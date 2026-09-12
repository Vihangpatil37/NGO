import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/socket/patient_socket_service.dart';
import '../../core/models/token_status.dart';

import '../../core/services/local_notification_service.dart';

class TokenProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PatientSocketService _socketService = PatientSocketService();
  final LocalNotificationService _localNotifService = LocalNotificationService();
  
  TokenStatus? _status;
  bool _isLoading = true;
  String? _error;
  String? _tokenId;

  TokenStatus? get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TokenProvider();

  Future<void> fetchStatus(String tokenId) async {
    _tokenId = tokenId;
    _setLoading(true);
    _clearError();

    try {
      final data = await _apiService.getTokenStatus(tokenId);
      if (data['success'] == true && data['data'] != null) {
        _status = TokenStatus.fromJson(data['data']);
        notifyListeners();
        _connectRealtime(tokenId);
      } else {
        _setError('error_load_token');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _connectRealtime(String tokenId) async {
    _socketService.connect(
      tokenId: tokenId,
      onTokenCalled: _handleTokenCalled,
      onTurnNear: _handleTurnNear,
      onNotification: _handleNotification,
      onQueueUpdated: _handleQueueUpdated,
    );
  }

  void _handleTokenCalled(dynamic data) {
    final tokenNum = data?['tokenNumber'] ?? _status?.tokenNumber;
    _localNotifService.showNotification(
      title: '🚨 YOUR TURN / તમારો વારો',
      body: 'Token #$tokenNum has been called. Please proceed to the doctor\'s room immediately.',
      priority: 'urgent',
    );

    if (_tokenId != null) {
      fetchStatus(_tokenId!);
    }
  }

  void _handleTurnNear(dynamic data) {
    final tokenNum = data?['tokenNumber'] ?? _status?.tokenNumber;
    final ahead = data?['patientsAhead'] ?? 3;
    _localNotifService.showNotification(
      title: '⏳ YOUR TURN IS NEAR / વારો નજીક છે',
      body: 'Token #$tokenNum: Only $ahead patient(s) ahead. Please be ready near the OPD room.',
      priority: 'high',
    );

    if (_tokenId != null) {
      fetchStatus(_tokenId!);
    }
  }

  void _handleNotification(dynamic data) {
    final title = data?['renderedTitle'] ?? data?['title'] ?? 'ArogyaMitra Alert';
    final body = data?['renderedBody'] ?? data?['message'] ?? '';
    final priority = data?['priority'] ?? 'high';

    _localNotifService.showNotification(
      title: title,
      body: body,
      priority: priority,
    );

    if (_tokenId != null) {
      fetchStatus(_tokenId!);
    }
  }

  void _handleQueueUpdated(dynamic data) {
    if (_tokenId != null) {
      // Re-fetch to get accurate queue positions and state
      fetchStatus(_tokenId!);
    }
  }

  Future<void> clearSession() async {
    _socketService.disconnect();
    final storage = await SessionStorage.getInstance();
    await storage.clearSession();
    _status = null;
    _tokenId = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
