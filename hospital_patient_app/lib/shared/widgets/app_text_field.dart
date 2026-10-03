import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String? helperText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.words,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceCard : Colors.white;
    final borderColor =
        isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isFocused
                ? primaryColor
                : (isDark ? AppColors.darkTextSecondary : AppColors.textPrimary),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withAlpha(isDark ? 50 : 30),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            maxLines: widget.maxLines,
            obscureText: widget.obscureText,
            textCapitalization: widget.textCapitalization,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? primaryColor
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF94A3B8)),
                        size: 22,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: surfaceColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: isDark ? AppColors.darkYourTurn : AppColors.yourTurn,
                    width: 1.4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: isDark ? AppColors.darkYourTurn : AppColors.yourTurn,
                    width: 2.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
