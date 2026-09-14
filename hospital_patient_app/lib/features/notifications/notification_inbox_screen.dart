import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/services/local_notification_service.dart';
import '../../shared/widgets/language_selector_sheet.dart';

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
      final list = res['data']?['notifications'] ?? [];

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

  Future<void> _markAsRead(String id) async {
    // try {
    //   await _apiService.markNotificationRead(id);
    //   _loadNotifications(); // Reload to refresh list and badge
    // } catch (_) {}
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'TOKEN_CALLED':
      case 'HOSPITAL_ANNOUNCEMENT':
        return Icons.campaign;
      case 'TURN_NEAR':
        return Icons.event_available;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'HOSPITAL_ANNOUNCEMENT':
        return AppColors.warning;
      case 'TOKEN_CALLED':
        return AppColors.error;
      case 'TURN_NEAR':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildNotificationCard(dynamic notif) {
    final bool isRead = notif['isRead'] == true;
    final String type = notif['type'] ?? 'GENERAL';
    final String title = notif['title'] ?? 'Notification';
    final String message = notif['message'] ?? '';
    final String time = 'Just now'; // Ideally format notif['createdAt'] here

    final iconColor = _getColorForType(type);
    final iconBgColor = iconColor.withOpacity(0.1);

    return InkWell(
      onTap: () {
        if (!isRead) _markAsRead(notif['_id']);
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isRead ? AppColors.border : AppColors.primaryLight,
            width: isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_getIconForType(type), color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
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
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead ? AppColors.textSecondary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isRead ? AppColors.textSecondary : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: AppSpacing.sm),
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If this screen is used inside PatientHomeShell, we don't want a scaffold back button.
    // We assume it's used inside the bottom nav shell.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button for bottom nav usage
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_notifications[index]);
                    },
                  ),
                ),
    );
  }
}
