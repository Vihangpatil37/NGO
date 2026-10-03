import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Material(
                  color: isDark ? AppColors.darkSurfaceCard : const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _LanguageTile(
              title: 'ગુજરાતી',
              subtitle: 'Gujarati',
              code: 'gu',
              onTap: () => _selectLocale(context, 'gu'),
            ),
            const SizedBox(height: 10),
            _LanguageTile(
              title: 'हिन्दी',
              subtitle: 'Hindi',
              code: 'hi',
              onTap: () => _selectLocale(context, 'hi'),
            ),
            const SizedBox(height: 10),
            _LanguageTile(
              title: 'English',
              subtitle: 'English',
              code: 'en',
              onTap: () => _selectLocale(context, 'en'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocale(BuildContext context, String code) async {
    await Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(code));
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = Localizations.localeOf(context).languageCode == code;
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.darkPrimary.withAlpha(35)
                    : AppColors.primaryLight.withAlpha(180))
                : (isDark ? AppColors.darkSurfaceCard : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.0 : 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
