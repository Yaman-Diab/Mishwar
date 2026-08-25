import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/entities/favorite_farm_entity.dart';

class FavoriteFarmCard extends StatelessWidget {
  final FavoriteFarmEntity farm;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteFarmCard({
    super.key,
    required this.farm,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final localeCode = context.locale.languageCode;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ImagePlaceholder(label: ''),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          colors.textPrimary.withValues(alpha: 0.55),
                          colors.textPrimary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  if (farm.isVerified)
                    PositionedDirectional(
                      top: 11.h,
                      start: 11.w,
                      child: _GlassChip(
                        colors: colors,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18.r,
                              height: 18.r,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: colors.background, size: 11.sp),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'favorites_verified_badge'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5.sp,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: 11.h,
                    end: 11.w,
                    child: InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.94),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite, color: colors.accent, size: 19.sp),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 11.h,
                    start: 13.w,
                    end: 13.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5.sp,
                                  color: colors.background,
                                ),
                              ),
                              if (farm.region != null) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 12.sp,
                                      color: colors.background.withValues(alpha: 0.85),
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        farm.region!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11.sp,
                                          color: colors.background.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (farm.rating != null) ...[
                          SizedBox(width: 8.w),
                          _GlassChip(
                            colors: colors,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 12.sp, color: colors.accent),
                                SizedBox(width: 4.w),
                                Text(
                                  farm.rating!.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5.sp,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 12.h, 15.w, 13.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        PriceFormatter.syp(farm.pricePerDay, localeCode: localeCode),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'favorites_view_details'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.arrow_back_ios_new
                            : Icons.arrow_forward_ios,
                        size: 11.sp,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final AppSemanticColors colors;
  final Widget child;

  const _GlassChip({required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
    );
  }
}
