import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? bottom;
  final double borderRadius;
  final bool showBackButton;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.bottom,
    this.borderRadius = 28,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Container(
      width: double.infinity,
      decoration: AppDecorations.gradientHeader(context, borderRadius: borderRadius),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showBackButton && (canPop || onBack != null)) ...[
                    Material(
                      color: Colors.white.withAlpha(45),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onBack ?? () => Navigator.maybePop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(210),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              if (bottom != null) ...[
                const SizedBox(height: 16),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
