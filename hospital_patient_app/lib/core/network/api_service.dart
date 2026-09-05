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
  }) async {
    try {
      final response = await _dio.post(
        '/cases/new',
        data: {
          'name': name,
          'villageName': villageName,
          'phoneNumber': phoneNumber,
          if (age != null) 'age': age,
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
      final response = await _dio.post(
        '/queue/register',
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
}

class DuplicateTokenException implements Exception {
  final String message;
  final String tokenId;
  
  DuplicateTokenException(this.message, this.tokenId);
  
  @override
  String toString() => message;
}
