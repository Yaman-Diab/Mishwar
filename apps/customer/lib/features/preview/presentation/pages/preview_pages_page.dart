import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../booking/presentation/pages/booking_args.dart';
import '../../../farm_details/presentation/models/farm_details_sample_data.dart';
import '../../../reviews/presentation/pages/submit_review_args.dart';

class PreviewPagesPage extends StatelessWidget {
  const PreviewPagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final farm = FarmDetailsSampleData.forLocale(context.locale);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('preview_title'.tr()),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              'preview_notice'.tr(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _PreviewTile(
            icon: Icons.landscape_outlined,
            title: 'preview_farm_details'.tr(),
            subtitle: 'preview_farm_details_description'.tr(),
            onTap: () => context.push('/farm-details'),
          ),
          _PreviewTile(
            icon: Icons.calendar_month_outlined,
            title: 'preview_booking'.tr(),
            subtitle: 'preview_booking_description'.tr(),
            onTap: () => context.push(
              '/booking',
              extra: BookingArgs(
                farmId: FarmDetailsSampleData.demoFarmId,
                farmName: farm.name,
                location: farm.location,
                isVerified: true,
                pricePerDay: farm.pricePerDayRaw,
                maxGuests: farm.maxGuests,
              ),
            ),
          ),
          _PreviewTile(
            icon: Icons.event_note_outlined,
            title: 'preview_my_bookings'.tr(),
            subtitle: 'preview_backend_description'.tr(),
            onTap: () => context.push('/my-bookings'),
          ),
          _PreviewTile(
            icon: Icons.favorite_border,
            title: 'preview_favorites'.tr(),
            subtitle: 'preview_backend_description'.tr(),
            onTap: () => context.push('/favorites'),
          ),
          _PreviewTile(
            icon: Icons.rate_review_outlined,
            title: 'preview_submit_review'.tr(),
            subtitle: 'preview_review_description'.tr(),
            onTap: () => context.push(
              '/submit-review',
              extra: SubmitReviewArgs(
                bookingId: '00000000-0000-0000-0000-000000000002',
                farmId: FarmDetailsSampleData.demoFarmId,
                farmName: farm.name,
                checkIn: DateTime.now(),
                checkOut: DateTime.now().add(const Duration(days: 1)),
                guests: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PreviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colors.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
