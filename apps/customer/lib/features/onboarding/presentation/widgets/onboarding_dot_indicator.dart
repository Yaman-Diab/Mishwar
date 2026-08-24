import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

/// نقطة تقدّم واحدة: تتسع من 8 إلى 28px وتتدرّج لونياً نحو الأخضر
/// الأساسي كلما اقتربت الصفحة الحالية منها — مطابق لصيغة التصميم
/// `width = 8 + t*20`، `color = mix(border, primary, t)`.
class OnboardingDotIndicator extends StatelessWidget {
  final double distanceFromCurrentPage;
  final AppSemanticColors colors;

  const OnboardingDotIndicator({
    super.key,
    required this.distanceFromCurrentPage,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final t = (1 - distanceFromCurrentPage.abs()).clamp(0.0, 1.0);
    return Container(
      width: (8 + t * 20).w,
      height: 8.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Color.lerp(colors.border, colors.primary, t),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
