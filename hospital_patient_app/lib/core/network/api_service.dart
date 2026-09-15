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

  /// Register a new case and receive a token number immediately
  Future<Map<String, dynamic>> registerNewCase({
    required String name,
    required String villageName,
    required String phoneNumber,
    int? age,
    String? preferredLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/cases/new',
        data: {
          'name': name,
          'villageName': villageName,
          'phoneNumber': phoneNumber,
          if (age != null) 'age': age,
          if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
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
    String? preferredLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/queue/register',
        data: {
          'phoneNumber': phoneNumber,
          'caseNumber': caseNumber,
          if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Update user language preference
  Future<void> updateLanguagePreference({required String patientId, required String languageCode}) async {
    try {
      await _dio.patch('/language', data: {'patientId': patientId, 'preferredLanguage': languageCode});
    } catch (_) {}
  }

  String _parseError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;

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

  // --- Notification APIs ---

  /// Register device FCM token for push notifications
  Future<void> registerDeviceToken({
    required String patientId,
    required String token,
    String platform = 'android',
    String locale = 'en',
  }) async {
    try {
      await _dio.post(
        '$baseUrl/api/v1/notifications/device-token',
        data: {
          'patientId': patientId,
          'token': token,
          'platform': platform,
          'locale': locale,
        },
      );
    } catch (_) {
      // Non-blocking background registration
    }
  }

  /// Get In-App Inbox notification history
  Future<Map<String, dynamic>> getNotifications({
    String? patientId,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/v1/notifications',
        queryParameters: {
          if (patientId != null) 'patientId': patientId,
          'page': page,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount({String? patientId}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/v1/notifications/unread-count',
        queryParameters: {
          if (patientId != null) 'patientId': patientId,
        },
      );
      return response.data?['data']?['unreadCount'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.patch('$baseUrl/api/v1/notifications/$notificationId/read');
    } catch (_) {}
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
