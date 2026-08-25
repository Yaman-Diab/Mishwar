import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../reviews/presentation/pages/submit_review_args.dart';
import '../cubit/my_bookings_cubit.dart';
import '../cubit/my_bookings_state.dart';
import '../widgets/booking_list_item.dart';

enum _Tab { current, past, cancelled }

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyBookingsCubit>(),
      child: const _MyBookingsView(),
    );
  }
}

class _MyBookingsView extends StatefulWidget {
  const _MyBookingsView();

  @override
  State<_MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<_MyBookingsView> {
  _Tab _tab = _Tab.current;

  List<BookingEntity> _filter(List<BookingEntity> all, _Tab tab) {
    return all.where((b) {
      return switch (tab) {
        _Tab.current => b.status == BookingStatus.pending || b.status == BookingStatus.confirmed,
        _Tab.past => b.status == BookingStatus.completed,
        _Tab.cancelled =>
          b.status == BookingStatus.rejected || b.status == BookingStatus.cancelled,
      };
    }).toList();
  }

  void _openReviewForm(BookingEntity booking) {
    context.push(
      '/submit-review',
      extra: SubmitReviewArgs(
        bookingId: booking.id,
        farmId: booking.farmId,
        farmName: booking.farmName,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
        guests: booking.guests,
      ),
    );
  }

  void _showToast(String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r)),
          margin: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 20.h),
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      builder: (context, state) {
        final current = _filter(state.bookings, _Tab.current);
        final past = _filter(state.bookings, _Tab.past);
        final cancelled = _filter(state.bookings, _Tab.cancelled);
        final visible = switch (_tab) {
          _Tab.current => current,
          _Tab.past => past,
          _Tab.cancelled => cancelled,
        };

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(colors, state.bookings.length),
                _buildTabs(colors, current.length, past.length, cancelled.length),
                Expanded(
                  child: RefreshIndicator(
                    color: colors.primary,
                    onRefresh: () => context.read<MyBookingsCubit>().load(),
                    child: state.loading && state.bookings.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : state.errorMessageKey != null && state.bookings.isEmpty
                        ? _buildError(colors, state.errorMessageKey!)
                        : visible.isEmpty
                        ? _buildEmpty(colors, _tab)
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(22.w, 6.h, 22.w, 24.h),
                            itemCount: visible.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) => BookingListItem(
                              booking: visible[index],
                              onRate: () => _openReviewForm(visible[index]),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppSemanticColors colors, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'my_bookings_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'my_bookings_total_count'.plural(total),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AppSemanticColors colors, int currentCount, int pastCount, int cancelledCount) {
    final tabs = [
      (_Tab.current, 'my_bookings_tab_current'.tr(), currentCount),
      (_Tab.past, 'my_bookings_tab_past'.tr(), pastCount),
      (_Tab.cancelled, 'my_bookings_tab_cancelled'.tr(), cancelledCount),
    ];
    final index = _Tab.values.indexOf(_tab);

    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 0),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(13.r)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional(-1 + index * 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: 0.12),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: tabs.map((t) {
                final active = t.$1 == _tab;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = t.$1),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.$2,
                            style: TextStyle(
                              fontWeight: active ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13.sp,
                              color: active ? colors.primary : colors.textSecondary,
                            ),
                          ),
                          if (t.$3 > 0) ...[
                            SizedBox(width: 5.w),
                            Container(
                              constraints: BoxConstraints(minWidth: 17.r),
                              height: 17.r,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: active
                                    ? colors.primary
                                    : colors.textSecondary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(9.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${t.$3}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                  color: active ? colors.background : colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppSemanticColors colors, _Tab tab) {
    final (titleKey, bodyKey) = switch (tab) {
      _Tab.current => ('my_bookings_empty_current_title', 'my_bookings_empty_current_body'),
      _Tab.past => ('my_bookings_empty_past_title', 'my_bookings_empty_past_body'),
      _Tab.cancelled => ('my_bookings_empty_cancelled_title', 'my_bookings_empty_cancelled_body'),
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(30.w, 60.h, 30.w, 40.h),
      children: [
        Icon(Icons.event_note_outlined, size: 72.sp, color: colors.primary.withValues(alpha: 0.45)),
        SizedBox(height: 22.h),
        Text(
          titleKey.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17.sp,
            height: 1.5,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          bodyKey.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, height: 1.8, color: colors.textSecondary),
        ),
        if (tab == _Tab.current) ...[
          SizedBox(height: 24.h),
          Center(
            child: ElevatedButton(
              onPressed: () => _showToast('my_bookings_explore_placeholder_toast'.tr()),
              child: Text(
                'my_bookings_explore_cta'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5.sp),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError(AppSemanticColors colors, String messageKey) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 80.h),
      children: [
        Icon(Icons.wifi_off_rounded, size: 48.sp, color: colors.textSecondary),
        SizedBox(height: 16.h),
        Text(
          'my_bookings_load_error'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, height: 1.7, color: colors.textSecondary),
        ),
      ],
    );
  }
}
