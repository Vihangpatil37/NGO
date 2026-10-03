import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/session_storage.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;

  ApiService({String? url}) : baseUrl = url ?? AppConstants.defaultApiUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl${AppConstants.apiBasePath}',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request interceptor to attach Bearer session token if available
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = await SessionStorage.getInstance();
          final token = storage.getSessionToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getDeviceId() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      debugPrint('Failed to get device ID: $e');
    }
    return null;
  }

  /// Register a new case and receive a token number immediately
  Future<Map<String, dynamic>> registerNewCase({
    required String name,
    required String villageName,
    required String phoneNumber,
    int? age,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      debugPrint('==== DEVICE ID ==== : $deviceId');
      final response = await _dio.post(
        '/cases/new',
        data: {
          'name': name,
          'villageName': villageName,
          'phoneNumber': phoneNumber,
          if (age != null) 'age': age,
          'deviceId': deviceId, // Force sending it even if null, so backend receives null
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Lookup returning patient by phone and Case ID (U-00000)
  Future<Map<String, dynamic>> lookupCase({
    required String phoneNumber,
    required String caseNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/cases/lookup',
        data: {
          'phoneNumber': phoneNumber,
          'caseNumber': caseNumber,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Register returning case for today's queue
  Future<Map<String, dynamic>> registerOldCase({
    required String phoneNumber,
    required String caseNumber,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      debugPrint('==== OLD CASE DEVICE ID ==== : $deviceId');
      final response = await _dio.post(
        '/queue/register',
        data: {
          'phoneNumber': phoneNumber,
          'caseNumber': caseNumber,
          'deviceId': deviceId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Fetch latest live token status
  Future<Map<String, dynamic>> getTokenStatus(String tokenId) async {
    try {
      final response = await _dio.get(
        '/token',
        queryParameters: {'tokenId': tokenId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Public hospital queue overview
  Future<Map<String, dynamic>> getHospitalStatus() async {
    try {
      final response = await _dio.get('/queue/status');
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  String _parseError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      
      if (e.response?.statusCode == 409 && data is Map && data['existing_token_id'] != null) {
        throw DuplicateTokenException(
          data['message'] ?? data['error']?.toString() ?? 'You already have an active token.',
          data['existing_token_id'],
        );
      }

      if (data is Map && data['error'] != null) {
        if (data['error'] is Map && data['error']['message'] != null) {
          return data['error']['message'];
        }
        if (data['error'] is String) {
          return data['error'];
        }
      }
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to hospital server. Please check your network.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // --- Doctor API ---

  Future<Map<String, dynamic>> doctorLogin({
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: '$baseUrl${AppConstants.doctorApiBasePath}',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      final response = await dio.post('/login', data: {
        'phoneNumber': phoneNumber,
        'pin': pin,
      });
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Map<String, dynamic>> getDoctorProfile(String token) async {
    try {
      final dio = _createDoctorDio(token);
      final response = await dio.get('/me');
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Map<String, dynamic>> getDoctorAvailability(String token) async {
    try {
      final dio = _createDoctorDio(token);
      final response = await dio.get('/availability');
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<Map<String, dynamic>> submitDoctorAvailability(
    String token,
    String status,
  ) async {
    try {
      final dio = _createDoctorDio(token);
      final response = await dio.post('/availability', data: {
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Dio _createDoctorDio(String token) {
    return Dio(BaseOptions(
      baseUrl: '$baseUrl${AppConstants.doctorApiBasePath}',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ));
  }
}

class DuplicateTokenException implements Exception {
  final String message;
  final String tokenId;
  
  DuplicateTokenException(this.message, this.tokenId);
  
  @override
  String toString() => message;
}
