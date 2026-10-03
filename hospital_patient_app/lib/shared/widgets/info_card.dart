import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppDecorations.glassCard(
        context,
        radius: borderRadius,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}
