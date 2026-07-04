// lib/features/home/widgets/premium_button.dart (shared widget)

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum PremiumButtonStyle { filled, outlined, danger }

class PremiumButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final bool isLoading;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.style = PremiumButtonStyle.filled,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null || isLoading;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (style) {
      case PremiumButtonStyle.filled:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = Colors.white;
        border = null;
        break;
      case PremiumButtonStyle.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        border = Border.all(color: theme.colorScheme.primary, width: 1.5);
        break;
      case PremiumButtonStyle.danger:
        backgroundColor = AppTheme.stopRed;
        foregroundColor = Colors.white;
        border = null;
        break;
    }

    if (disabled && style == PremiumButtonStyle.filled) {
      backgroundColor = backgroundColor.withOpacity(0.4);
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(foregroundColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: foregroundColor, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
