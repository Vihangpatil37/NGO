import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import 'package:hospital_patient_app/l10n/app_localizations.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFE0E0E0),
            width: isSelected ? 2.0 : 1.0,
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
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF212121),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0D47A1),
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}
