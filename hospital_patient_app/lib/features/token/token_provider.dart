import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/socket/patient_socket_service.dart';
import '../../core/models/token_status.dart';

import '../../core/services/local_notification_service.dart';
import '../../core/navigation/app_router.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

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

  bool _isSocketConnected = false;

  Future<void> fetchStatus(String tokenId, {bool silent = false}) async {
    _tokenId = tokenId;
    if (!silent) {
      _setLoading(true);
      _clearError();
    }

    try {
      final data = await _apiService.getTokenStatus(tokenId);
      if (data['success'] == true && data['data'] != null) {
        _status = TokenStatus.fromJson(data['data']);
        notifyListeners();
        if (!_isSocketConnected) {
          _connectRealtime(tokenId);
          _isSocketConnected = true;
        }
      } else {
        if (!silent) _setError('error_load_token');
      }
    } catch (e) {
      if (!silent) _setError(e.toString());
    } finally {
      if (!silent) _setLoading(false);
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
    if (_tokenId != null) {
      fetchStatus(_tokenId!, silent: true);
    }
  }

  void _handleTurnNear(dynamic data) {
    if (_tokenId != null) {
      fetchStatus(_tokenId!, silent: true);
    }
  }

  void _handleNotification(dynamic data) {
    if (_tokenId != null) {
      fetchStatus(_tokenId!, silent: true);
    }
  }

  void _handleQueueUpdated(dynamic data) {
    if (_tokenId != null) {
      // Re-fetch to get accurate queue positions and state
      fetchStatus(_tokenId!, silent: true);
    }
  }

  Future<void> clearSession() async {
    _socketService.disconnect();
    _isSocketConnected = false;
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
