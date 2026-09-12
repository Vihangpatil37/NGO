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

  Future<void> _markAsRead(String notifId, int index) async {
    await _apiService.markNotificationAsRead(notifId);
    if (mounted) {
      setState(() {
        _notifications[index]['readAt'] = DateTime.now().toIso8601String();
      });
    }
  }

  Future<void> _triggerNotification({
    required String title,
    required String body,
    required String priority,
    required String type,
  }) async {
    await _notifService.showNotification(
      title: title,
      body: body,
      priority: priority,
    );

    setState(() {
      _notifications.insert(0, {
        '_id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'type': type,
        'priority': priority,
        'renderedTitle': title,
        'renderedBody': body,
        'createdAt': DateTime.now().toIso8601String(),
        'readAt': null,
      });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 $title dispatched!'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: priority == 'urgent' ? AppColors.danger : AppColors.primary,
        ),
      );
    }
  }

  Future<void> _triggerAllSequentially() async {
    final tests = [
      {
        'type': 'REGISTRATION_CONFIRMED',
        'title': '✅ Registration Confirmed',
        'body': 'Your OPD token is #27. Please keep this token with you.',
        'priority': 'normal'
      },
      {
        'type': 'TURN_NEAR',
        'title': '⏳ Your Turn Is Near',
        'body': 'Your token #27 is coming soon. Only 3 patients ahead.',
        'priority': 'high'
      },
      {
        'type': 'TOKEN_CALLED',
        'title': '🚨 YOUR TURN',
        'body': 'Token #27 has been called. Please proceed to Doctor Room 1.',
        'priority': 'urgent'
      },
      {
        'type': 'HOSPITAL_ANNOUNCEMENT',
        'title': '📢 Hospital Notice',
        'body': 'OPD registration will close at 12:30 PM today.',
        'priority': 'high'
      },
      {
        'type': 'DOCTOR_UNAVAILABLE',
        'title': '🩺 Doctor Unavailable',
        'body': 'Dr. Rajesh Sharma is unavailable today. Please visit registration desk.',
        'priority': 'high'
      },
      {
        'type': 'OPD_CLOSED',
        'title': '🚪 OPD Closed',
        'body': 'Today\'s OPD session has closed. OPD resumes tomorrow at 9:00 AM.',
        'priority': 'urgent'
      },
    ];

    for (int i = 0; i < tests.length; i++) {
      final t = tests[i];
      await _triggerNotification(
        title: t['title']!,
        body: t['body']!,
        priority: t['priority']!,
        type: t['type']!,
      );
      if (i < tests.length - 1) {
        await Future.delayed(const Duration(milliseconds: 1800));
      }
    }
  }

  void _showTestSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🧪 Test All 6 Notification Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap any alert below or run all 6 sequentially to test sound, heads-up status bar banners, and vibrations on your device.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('🚀 Trigger All 6 Notifications Sequentially', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _triggerAllSequentially();
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _TestItem(
              title: 'Registration Confirmed',
              subtitle: 'Token #27 allocated (Normal priority)',
              color: AppColors.primary,
              icon: Icons.check_circle_outline,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'REGISTRATION_CONFIRMED',
                  title: '✅ Registration Confirmed',
                  body: 'Your registration is successful. Your OPD token is #27.',
                  priority: 'normal',
                );
              },
            ),
            _TestItem(
              title: 'Turn Near',
              subtitle: '3 patients ahead warning (High priority)',
              color: AppColors.warning,
              icon: Icons.access_time_filled_rounded,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'TURN_NEAR',
                  title: '⏳ Your Turn Is Near',
                  body: 'Your token #27 is coming soon. Only 3 patients ahead.',
                  priority: 'high',
                );
              },
            ),
            _TestItem(
              title: 'Token Called',
              subtitle: 'Proceed to doctor (Urgent priority + vibration)',
              color: AppColors.danger,
              icon: Icons.campaign_rounded,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'TOKEN_CALLED',
                  title: '🚨 YOUR TURN',
                  body: 'Token #27 has been called. Please proceed to Doctor Room 1.',
                  priority: 'urgent',
                );
              },
            ),
            _TestItem(
              title: 'Hospital Announcement',
              subtitle: 'Broadcast operational notice (High priority)',
              color: Colors.indigo,
              icon: Icons.info_outline_rounded,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'HOSPITAL_ANNOUNCEMENT',
                  title: '📢 Hospital Notice',
                  body: 'OPD registration will close at 12:30 PM today.',
                  priority: 'high',
                );
              },
            ),
            _TestItem(
              title: 'Doctor Unavailable',
              subtitle: 'Doctor cancellation alert (High priority)',
              color: Colors.deepOrange,
              icon: Icons.event_busy_rounded,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'DOCTOR_UNAVAILABLE',
                  title: '🩺 Doctor Unavailable',
                  body: 'Dr. Rajesh Sharma is unavailable today. Please visit registration desk.',
                  priority: 'high',
                );
              },
            ),
            _TestItem(
              title: 'OPD Closed',
              subtitle: 'OPD session concluded (Urgent priority)',
              color: Colors.red[900]!,
              icon: Icons.door_front_door_outlined,
              onTap: () {
                Navigator.pop(ctx);
                _triggerNotification(
                  type: 'OPD_CLOSED',
                  title: '🚪 OPD Closed',
                  body: 'Today\'s OPD session has closed. OPD resumes tomorrow at 9:00 AM.',
                  priority: 'urgent',
                );
              },
            ),
          ],
        ),
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.primary),
            tooltip: 'Test All 6 Alerts',
            onPressed: _showTestSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Notifications',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.notifications_active_rounded),
        label: const Text('Test 6 Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showTestSheet,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
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
                          'No Notifications Yet',
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
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text('Test All 6 Notification Alerts'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _showTestSheet,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
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

                    return InkWell(
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
                    );
                  },
                ),
    );
  }
}

class _TestItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TestItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
      onTap: onTap,
    );
  }
}
