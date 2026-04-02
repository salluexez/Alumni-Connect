import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final Gradient? gradient;
  final BoxShape shape;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderRadius = AppSizes.radiusLg,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.gradient,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle ? BorderRadius.zero : BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              shape: shape,
              borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
              color: AppColors.glassBase.withValues(alpha: opacity),
              border: border ?? Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.2),
                width: 1.5,
              ),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
