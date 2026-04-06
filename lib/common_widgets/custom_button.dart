import 'package:flutter/material.dart';
import '../theme/color.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.minWidth,
    this.textStyle,
    this.padding,
    this.borderRadius = 12,
    this.icon,
    this.iconPosition = IconPosition.left,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? minWidth;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? icon;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? Colors.white;
    final isButtonEnabled = enabled && !isLoading && onPressed != null;

    return SizedBox(
      height: height,
      width: minWidth ?? double.infinity,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? () {
                if (!isLoading) onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled
              ? effectiveBackgroundColor
              : effectiveBackgroundColor.withValues(alpha: 0.5),
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.7),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : _buildContent(context, effectiveTextColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color effectiveTextColor) {
    final label = Text(
      text,
      style: textStyle ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.w600,
              ),
    );

    if (icon == null) return label;

    const gap = SizedBox(width: 8);
    return iconPosition == IconPosition.left
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon!, gap, label],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [label, gap, icon!],
          );
  }
}

enum IconPosition { left, right }
