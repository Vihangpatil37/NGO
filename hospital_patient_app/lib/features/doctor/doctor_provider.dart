import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';

class DoctorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Doctor profile
  String? _doctorObjectId;
  String? _doctorPhone;
  String? _doctorName;
  String? _specialization;
  String? _token;

  // Availability
  String? _availabilityStatus; // 'coming' | 'not_coming' | null
  String? _respondedAt;
  String? _windowId;
  String? _windowDate;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get doctorPhone => _doctorPhone;
  String? get doctorName => _doctorName;
  String? get specialization => _specialization;
  String? get token => _token;
  String? get availabilityStatus => _availabilityStatus;
  String? get respondedAt => _respondedAt;
  String? get windowId => _windowId;
  String? get windowDate => _windowDate;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// Attempt login with doctor credentials
  Future<bool> login(String phoneNumber, String pin) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.doctorLogin(
        phoneNumber: phoneNumber,
        pin: pin,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _token = data['token'];
        final doctor = data['doctor'];
        _doctorObjectId = doctor['id']?.toString();
        _doctorPhone = doctor['phoneNumber'];
        _doctorName = doctor['name'];
        _specialization = doctor['specialization'];

        // Persist doctor session
        final storage = await SessionStorage.getInstance();
        await storage.saveDoctorSession(
          token: _token!,
          doctorPhone: _doctorPhone!,
          doctorObjectId: _doctorObjectId!,
          doctorName: _doctorName!,
          specialization: _specialization,
        );

        _setLoading(false);
        return true;
      } else {
        _setError(response['error']?['message'] ?? 'Invalid doctor credentials');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Restore session from storage
  Future<bool> restoreSession() async {
    final storage = await SessionStorage.getInstance();
    if (!storage.hasDoctorSession()) return false;

    _token = storage.getDoctorSessionToken();
    _doctorPhone = storage.getDoctorPhone();
    _doctorObjectId = storage.getDoctorObjectId();
    _doctorName = storage.getDoctorName();
    _specialization = storage.getDoctorSpecialization();

    // Validate token by fetching profile
    try {
      final response = await _apiService.getDoctorProfile(_token!);
      if (response['success'] == true) {
        final doctor = response['data']?['doctor'];
        if (doctor != null) {
          _doctorName = doctor['name'];
          _specialization = doctor['specialization'];
          notifyListeners();
          return true;
        }
      }
    } catch (_) {
      // Token expired or invalid
    }

    // Session invalid, clear it
    await logout();
    return false;
  }

  /// Load today's availability status
  Future<void> loadAvailability() async {
    if (_token == null) return;
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getDoctorAvailability(_token!);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final window = data['registrationWindow'];
        _windowId = window?['id'];
        _windowDate = window?['date'];

        final availability = data['availability'];
        if (availability != null) {
          _availabilityStatus = availability['status'];
          _respondedAt = availability['respondedAt'];
        } else {
          _availabilityStatus = null;
          _respondedAt = null;
        }
      }
    } catch (e) {
      _setError('Could not load availability');
    } finally {
      _setLoading(false);
    }
  }

  /// Submit availability (coming / not_coming)
  Future<bool> submitAvailability(String status) async {
    if (_token == null) return false;
    _isSubmitting = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _apiService.submitDoctorAvailability(
        _token!,
        status,
      );

      if (response['success'] == true && response['data'] != null) {
        final availability = response['data']['availability'];
        _availabilityStatus = availability['status'];
        _respondedAt = availability['respondedAt'];
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _setError('Could not save availability');
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('Could not save availability. Please try again.');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear doctor session
  Future<void> logout() async {
    final storage = await SessionStorage.getInstance();
    await storage.clearDoctorSession();

    _token = null;
    _doctorPhone = null;
    _doctorObjectId = null;
    _doctorName = null;
    _specialization = null;
    _availabilityStatus = null;
    _respondedAt = null;
    _windowId = null;
    _windowDate = null;
    _error = null;
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
  }
}
