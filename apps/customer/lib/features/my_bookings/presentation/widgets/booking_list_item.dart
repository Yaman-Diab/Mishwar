import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../booking/domain/entities/booking_entity.dart';

class BookingListItem extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onRate;

  const BookingListItem({super.key, required this.booking, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final localeCode = context.locale.languageCode;
    final format = DateFormat('d MMM', localeCode);
    final dates = '${format.format(booking.checkIn)} – ${format.format(booking.checkOut)}';
    final price = booking.totalPrice != null
        ? PriceFormatter.syp(booking.totalPrice!, localeCode: localeCode)
        : 'booking_price_placeholder'.tr();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.055),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(13.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(width: 68.w, height: 68.h, color: colors.border),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              booking.farmName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5.sp,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            price,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13.sp, color: colors.textSecondary),
                          SizedBox(width: 6.w),
                          Text(
                            dates,
                            style: TextStyle(fontSize: 11.5.sp, color: colors.textSecondary),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: colors.textSecondary.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'booking_guests_count'.plural(booking.guests),
                            style: TextStyle(fontSize: 11.5.sp, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      _StatusBadge(colors: colors, status: booking.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (booking.status == BookingStatus.completed)
            Padding(
              padding: EdgeInsets.fromLTRB(13.w, 0, 13.w, 13.h),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onRate,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      minimumSize: Size(0, 36.h),
                    ),
                    icon: Icon(Icons.star_border_rounded, size: 15.sp, color: colors.primary),
                    label: Text(
                      'my_bookings_rate_experience'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'my_bookings_rate_helper'.tr(),
                      style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppSemanticColors colors;
  final BookingStatus status;

  const _StatusBadge({required this.colors, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, key, showDot) = switch (status) {
      BookingStatus.pending => (
          colors.warning.withValues(alpha: 0.16),
          colors.warning,
          'my_bookings_status_pending',
          false,
        ),
      BookingStatus.confirmed => (
          colors.success.withValues(alpha: 0.16),
          colors.success,
          'my_bookings_status_confirmed',
          true,
        ),
      BookingStatus.completed => (
          colors.secondary,
          colors.textPrimary,
          'my_bookings_status_completed',
          false,
        ),
      BookingStatus.rejected => (
          colors.textSecondary.withValues(alpha: 0.13),
          colors.error,
          'my_bookings_status_rejected',
          true,
        ),
      BookingStatus.cancelled => (
          colors.textSecondary.withValues(alpha: 0.13),
          colors.error,
          'my_bookings_status_cancelled',
          true,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            key.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: fg),
          ),
        ],
      ),
    );
  }
}
