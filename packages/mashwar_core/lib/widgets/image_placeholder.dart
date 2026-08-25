import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme_context.dart';

/// حالة فارغة واضحة (أيقونة + نص) لمكان بانتظار صورة حقيقية — بدل صورة
/// وهمية قد تُفهم كمحتوى فعلي. تُستخدم بأي شاشة تعرض صوراً بلا مصدر
/// حقيقي مربوط بعد (تفاصيل المزرعة، صور التقييم، إلخ).
class ImagePlaceholder extends StatelessWidget {
  final String label;
  final double borderRadius;

  const ImagePlaceholder({super.key, required this.label, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: colors.border,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: colors.textSecondary, size: 28.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
