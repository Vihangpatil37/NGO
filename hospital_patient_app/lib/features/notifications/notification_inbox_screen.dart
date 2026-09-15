import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/services/local_notification_service.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final ApiService _apiService = ApiService();
  final LocalNotificationService _notifService = LocalNotificationService();
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final storage = await SessionStorage.getInstance();
      _patientId = storage.getPatientId();

      final res = await _apiService.getNotifications(patientId: _patientId);
      var list = res['data']?['notifications'] ?? [];
      
      final clearedAtStr = storage.getNotificationsClearedAt();
      final clearedAt = clearedAtStr != null ? DateTime.parse(clearedAtStr) : null;

      if (clearedAt != null) {
        list = list.where((n) {
          if (n['createdAt'] == null) return true;
          final dt = DateTime.tryParse(n['createdAt']);
          return dt != null && dt.isAfter(clearedAt);
        }).toList();
      }

      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Remove/clear all notifications from the app & notification bar
  Future<void> _clearAllNotifications() async {
    setState(() => _isLoading = true);
    
    // Cancel all system tray notifications
    await _notifService.cancelAll();

    final storage = await SessionStorage.getInstance();
    await storage.setNotificationsClearedAt(DateTime.now().toUtc().toIso8601String());

    // Clear all in-app notifications
    if (mounted) {
      setState(() {
        _notifications.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ All notifications cleared.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsRead(String notifId, int index) async {
    await _apiService.markNotificationAsRead(notifId);
    if (mounted) {
      setState(() {
        _notifications[index]['readAt'] = DateTime.now().toIso8601String();
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'REGISTRATION_CONFIRMED':
        return Icons.check_circle_outline_rounded;
      case 'TURN_NEAR':
        return Icons.access_time_filled_rounded;
      case 'TOKEN_CALLED':
        return Icons.campaign_rounded;
      case 'HOSPITAL_ANNOUNCEMENT':
        return Icons.info_outline_rounded;
      case 'DOCTOR_UNAVAILABLE':
        return Icons.event_busy_rounded;
      case 'OPD_CLOSED':
        return Icons.door_front_door_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getColorForType(String type, String priority) {
    if (priority == 'urgent') return AppColors.danger;
    if (priority == 'high') return const Color(0xFFF57F17);
    switch (type) {
      case 'REGISTRATION_CONFIRMED':
        return AppColors.primary;
      case 'TURN_NEAR':
        return const Color(0xFFF57F17);
      case 'TOKEN_CALLED':
        return AppColors.yourTurn;
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications & Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
              tooltip: 'Clear All Notifications',
              onPressed: _clearAllNotifications,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Notifications',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _notifications.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 72,
                            color: AppColors.textSecondary.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You will receive real-time alerts for your token status, turn warnings, and hospital updates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _loadNotifications,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final isRead = item['readAt'] != null;
                      final type = item['type'] ?? 'HOSPITAL_ANNOUNCEMENT';
                      final priority = item['priority'] ?? 'normal';
                      final color = _getColorForType(type, priority);
                      final icon = _getIconForType(type);

                      final title = item['renderedTitle'] ?? item['titleKey'] ?? 'Notice';
                      final body = item['renderedBody'] ?? item['bodyKey'] ?? '';
                      final notifId = item['_id']?.toString() ?? '';

                      return Dismissible(
                        key: Key(notifId.isNotEmpty ? notifId : 'notif_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            _notifications.removeAt(index);
                          });
                        },
                        child: InkWell(
                          onTap: () {
                            if (!isRead && notifId.isNotEmpty) {
                              _markAsRead(notifId, index);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isRead ? AppColors.surface : color.withAlpha(12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRead ? AppColors.border : color.withAlpha(80),
                                width: isRead ? 1.0 : 1.8,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: color, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                                color: isRead ? AppColors.textPrimary : color,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        body,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
