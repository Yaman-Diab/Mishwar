import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

/// بديل عن عنصر `<image-slot>` بالتصميم (ملء صورة حقيقية بأداة التصميم
/// فقط) — بانتظار ربط فعلي بصور Supabase Storage، نعرض حالة فارغة
/// واضحة (أيقونة + نص) بدل صورة وهمية قد تُفهم كمحتوى حقيقي.
class FarmImagePlaceholder extends StatelessWidget {
  final String label;
  final double borderRadius;

  const FarmImagePlaceholder({super.key, required this.label, this.borderRadius = 0});

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
