import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../constants/app_constants.dart';

class PatientSocketService {
  socket_io.Socket? _socket;
  final String serverUrl;

  PatientSocketService({String? url}) : serverUrl = url ?? AppConstants.defaultApiUrl;

  void connect({
    String? registrationId,
    String? tokenId,
    Function(dynamic)? onTokenCalled,
    Function(dynamic)? onPositionUpdate,
    Function(dynamic)? onTokenCompleted,
    Function(dynamic)? onTokenCancelled,
    Function(dynamic)? onQueueUpdated,
    Function(dynamic)? onNotification,
    Function(dynamic)? onTurnNear,
  }) {
    disconnect();

    _socket = socket_io.io(
      serverUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('[Socket] Connected to $serverUrl');
      if (registrationId != null || tokenId != null) {
        _socket?.emit('join:patient', {
          'registrationId': registrationId,
          'tokenId': tokenId,
        });
      }
    });

    if (onTokenCalled != null) {
      _socket?.on('token:called', onTokenCalled);
    }

    if (onTurnNear != null) {
      _socket?.on('token:turn-near', onTurnNear);
    }

    if (onNotification != null) {
      _socket?.on('notification:new', onNotification);
    }

    if (onPositionUpdate != null) {
      _socket?.on('token:position-update', onPositionUpdate);
    }

    if (onTokenCompleted != null) {
      _socket?.on('token:completed', onTokenCompleted);
    }

    if (onTokenCancelled != null) {
      _socket?.on('token:cancelled', onTokenCancelled);
    }

    if (onQueueUpdated != null) {
      _socket?.on('queue:updated', onQueueUpdated);
    }

    // Broadcast notices
    _socket?.on('announcement:broadcast', (data) {
      if (onNotification != null) onNotification(data);
    });

    _socket?.onDisconnect((_) {
      debugPrint('[Socket] Disconnected from server');
    });

    _socket?.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    }
  }
}
