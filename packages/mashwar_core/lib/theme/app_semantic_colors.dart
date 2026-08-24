import 'package:flutter/material.dart';

import 'app_colors.dart';

/// توكنات ألوان حسب الدور (Role-Based) — الودجتات تقرأ منها عبر
/// [context.colors] بدل الرجوع لـ[AppColors] الخام مباشرة، لضمان تبديل
/// تلقائي بين الوضعين الفاتح والداكن.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color error;

  const AppSemanticColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const AppSemanticColors light = AppSemanticColors(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
  );

  /// ⚠️ قيم مؤقتة (نسخة عن اللايت) بانتظار استلام لوحة ألوان الدارك
  /// الفعلية من المستخدم — نقطة التصحيح الوحيدة عند استلامها.
  static const AppSemanticColors dark = AppSemanticColors(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
  );

  @override
  AppSemanticColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
