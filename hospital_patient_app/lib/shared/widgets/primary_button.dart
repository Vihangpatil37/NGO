import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final LinearGradient? gradient;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 56,
    this.borderRadius = 16,
    this.gradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final defaultGradient = widget.backgroundColor == null
        ? (widget.gradient ??
            (isDark
                ? const LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.primaryGradient))
        : null;

    final effectiveTextColor = widget.textColor ??
        (widget.backgroundColor != null
            ? Colors.white
            : (isDark ? Colors.black : Colors.white));

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          gradient: defaultGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (widget.backgroundColor ??
                            (isDark
                                ? AppColors.darkPrimary
                                : AppColors.primary))
                        .withAlpha(isDark ? 50 : 60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onHighlightChanged: (val) {
              if (mounted) setState(() => _isPressed = val);
            },
            onTap: isEnabled ? widget.onPressed : null,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 22, color: effectiveTextColor),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: effectiveTextColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
