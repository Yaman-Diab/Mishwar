import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/availability_day_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_calendar.dart';
import '../widgets/lock_countdown_ring.dart';
import 'booking_args.dart';

class BookingPage extends StatelessWidget {
  final BookingArgs args;

  const BookingPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingCubit>(),
      child: _BookingView(args: args),
    );
  }
}

class _BookingView extends StatefulWidget {
  final BookingArgs args;

  const _BookingView({required this.args});

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  late DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAvailability());
  }

  void _loadAvailability() {
    final from = _visibleMonth;
    final to = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    context.read<BookingCubit>().loadAvailability(
      farmId: widget.args.farmId,
      from: from,
      to: to,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _checkIn = null;
      _checkOut = null;
    });
    _loadAvailability();
  }

  Set<DateTime> _unavailableSet(List<AvailabilityDayEntity> availability) {
    return availability
        .where((d) => !d.isBookable)
        .map((d) => DateTime(d.day.year, d.day.month, d.day.day))
        .toSet();
  }

  void _onDayTap(DateTime day, List<AvailabilityDayEntity> availability) {
    final unavailable = _unavailableSet(availability);

    if (_checkIn == null || (_checkIn != null && _checkOut != null) || !day.isAfter(_checkIn!)) {
      setState(() {
        _checkIn = day;
        _checkOut = null;
      });
      return;
    }

    var cursor = _checkIn!.add(const Duration(days: 1));
    while (cursor.isBefore(day)) {
      if (unavailable.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
        _showToast('booking_blocked_day_in_range'.tr());
        return;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    setState(() => _checkOut = day);
  }

  void _submit() {
    if (_checkIn == null || _checkOut == null) {
      _showToast('booking_select_dates_error'.tr());
      return;
    }
    context.read<BookingCubit>().submit(
      farmId: widget.args.farmId,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      guests: _guests,
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
          duration: const Duration(milliseconds: 2400),
        ),
      );
  }

  int get _nights =>
      (_checkIn != null && _checkOut != null) ? _checkOut!.difference(_checkIn!).inDays : 0;

  double get _total => _nights * widget.args.pricePerDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.conflict) {
          _showToast('booking_conflict_message'.tr());
          setState(() {
            _checkIn = null;
            _checkOut = null;
          });
          _loadAvailability();
        } else if (state.errorMessageKey != null) {
          _showToast(state.errorMessageKey!.tr());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: switch (state.step) {
                    BookingStep.selecting => _buildSelecting(context, state),
                    BookingStep.awaiting => _buildAwaiting(context, state),
                    BookingStep.resolved => _buildResolved(context, state),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BookingState state) {
    final colors = context.colors;
    final titleKey = switch (state.step) {
      BookingStep.selecting => 'booking_header_selecting',
      BookingStep.awaiting => 'booking_header_awaiting',
      BookingStep.resolved => 'booking_header_status',
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 6.h),
      child: Row(
        children: [
          if (state.step == BookingStep.selecting)
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                  color: colors.surface,
                ),
                child: const BackButtonIcon(),
              ),
            ),
          if (state.step == BookingStep.selecting) SizedBox(width: 10.w),
          Text(
            titleKey.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelecting(BuildContext context, BookingState state) {
    final colors = context.colors;
    final ready = _nights > 0;
    final localeCode = context.locale.languageCode;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            children: [
              _buildFarmSummary(colors),
              BookingCalendar(
                visibleMonth: _visibleMonth,
                checkIn: _checkIn,
                checkOut: _checkOut,
                unavailableDays: _unavailableSet(state.availability),
                onDayTap: (day) => _onDayTap(day, state.availability),
                onPrevMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
              ),
              _buildGuestsCard(colors),
              _buildPriceCard(colors, ready, localeCode),
              _buildPolicyNote(colors),
            ],
          ),
        ),
        _buildSubmitBar(colors, state, ready, localeCode),
      ],
    );
  }

  Widget _buildFarmSummary(AppSemanticColors colors) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: Container(width: 62.w, height: 56.h, color: colors.border),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.farmName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    if (widget.args.isVerified) ...[
                      Container(
                        width: 16.r,
                        height: 16.r,
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                        child: Icon(Icons.check, color: colors.background, size: 10.sp),
                      ),
                      SizedBox(width: 5.w),
                    ],
                    Expanded(
                      child: Text(
                        widget.args.location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsCard(AppSemanticColors colors) {
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_guests_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5.sp,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'booking_guests_max'.tr(namedArgs: {'max': '${widget.args.maxGuests}'}),
                  style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                enabled: _guests > 1,
                onTap: () => setState(() => _guests--),
              ),
              SizedBox(width: 14.w),
              SizedBox(
                width: 26.w,
                child: Text(
                  '$_guests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17.sp,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              _StepperButton(
                icon: Icons.add,
                enabled: _guests < widget.args.maxGuests,
                onTap: () => setState(() => _guests++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(AppSemanticColors colors, bool ready, String localeCode) {
    final priceLine = ready
        ? '${PriceFormatter.syp(widget.args.pricePerDay, localeCode: localeCode)} × ${'booking_nights_count'.plural(_nights)}'
        : 'booking_select_dates_first'.tr();
    final totalLabel = ready
        ? PriceFormatter.syp(_total, localeCode: localeCode)
        : 'booking_price_placeholder'.tr();

    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _priceRow(colors, priceLine, totalLabel),
          SizedBox(height: 9.h),
          _priceRow(colors, 'booking_service_fee'.tr(), 'booking_free'.tr()),
          Container(height: 1, color: colors.border.withValues(alpha: 0.6), margin: EdgeInsets.symmetric(vertical: 12.h)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'booking_total'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5.sp,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                totalLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 19.sp,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(AppSemanticColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5.sp, color: colors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5.sp,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyNote(AppSemanticColors colors) {
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 17.sp, color: colors.textPrimary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_policy_moderate_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5.sp,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'booking_policy_moderate_description'.tr(),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.75,
                    color: colors.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(
    AppSemanticColors colors,
    BookingState state,
    bool ready,
    String localeCode,
  ) {
    final canSubmit = ready && !state.submitting;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: BorderDirectional(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ready ? colors.accent : colors.border,
                disabledBackgroundColor: colors.border,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: state.submitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      ready ? 'booking_submit_cta'.tr() : 'booking_choose_dates_cta'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            'booking_no_charge_note'.tr(),
            style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAwaiting(BuildContext context, BookingState state) {
    final colors = context.colors;
    final localeCode = context.locale.languageCode;
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 26.h),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LockCountdownRing(
                  remaining: state.remaining,
                  size: 212.r,
                  trackColor: colors.border,
                  progressColor: colors.primary,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.verifyingExpiry
                            ? '00:00'
                            : _formatDuration(state.remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 42.sp,
                          letterSpacing: 1,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        state.verifyingExpiry
                            ? 'booking_awaiting_verifying'.tr()
                            : 'booking_awaiting_countdown_label'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 34.h),
                Text(
                  'booking_awaiting_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'booking_awaiting_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5.sp, height: 1.8, color: colors.textSecondary),
                ),
                SizedBox(height: 22.h),
                Wrap(
                  spacing: 9.w,
                  runSpacing: 9.h,
                  alignment: WrapAlignment.center,
                  children: [
                    _Chip(colors: colors, label: _rangeLabel(booking, localeCode)),
                    _Chip(
                      colors: colors,
                      label: 'booking_guests_count'.plural(booking.guests),
                    ),
                    _Chip(
                      colors: colors,
                      label: booking.totalPrice != null
                          ? PriceFormatter.syp(booking.totalPrice!, localeCode: localeCode)
                          : 'booking_price_placeholder'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.read<BookingCubit>().cancelRequest(),
            child: Text(
              'booking_cancel_request'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5.sp,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolved(BuildContext context, BookingState state) {
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();

    return switch (booking.status) {
      BookingStatus.confirmed => _buildConfirmed(context, booking),
      BookingStatus.rejected => _buildRejected(context, booking),
      BookingStatus.cancelled => _buildCancelled(context),
      BookingStatus.completed => _buildCompleted(context),
      BookingStatus.pending => _buildAwaiting(context, state),
    };
  }

  Widget _buildConfirmed(BuildContext context, BookingEntity booking) {
    final colors = context.colors;
    final localeCode = context.locale.languageCode;

    return Padding(
      padding: EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 26.h),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.success, width: 4.r),
                  ),
                  child: Icon(Icons.check_circle, color: colors.success, size: 52.sp),
                ),
                SizedBox(height: 28.h),
                Text(
                  'booking_confirmed_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 21.sp,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'booking_confirmed_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5.sp, height: 1.8, color: colors.textSecondary),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(colors, 'booking_summary_farm'.tr(), booking.farmName),
                      SizedBox(height: 11.h),
                      _summaryRow(
                        colors,
                        'booking_summary_dates'.tr(),
                        _rangeLabel(booking, localeCode),
                      ),
                      SizedBox(height: 11.h),
                      _summaryRow(
                        colors,
                        'booking_summary_guests'.tr(),
                        'booking_guests_count'.plural(booking.guests),
                      ),
                      Container(height: 1, color: colors.border, margin: EdgeInsets.symmetric(vertical: 13.h)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'booking_total'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5.sp,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            booking.totalPrice != null
                                ? PriceFormatter.syp(booking.totalPrice!, localeCode: localeCode)
                                : 'booking_price_placeholder'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.sp,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => context.go('/my-bookings'),
              child: Text(
                'booking_view_booking'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejected(BuildContext context, BookingEntity booking) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 26.h),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88.r,
                  height: 88.r,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: colors.textSecondary, size: 36.sp),
                ),
                SizedBox(height: 26.h),
                Text(
                  'booking_rejected_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19.sp,
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'booking_rejected_reason_label'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        booking.rejectionReason ?? 'booking_rejected_no_reason'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.8,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'booking_rejected_note'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5.sp, height: 1.8, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          _retryButton(context),
        ],
      ),
    );
  }

  Widget _buildCancelled(BuildContext context) {
    final colors = context.colors;
    return _neutralResolvedView(
      context,
      icon: Icons.event_busy_outlined,
      title: 'booking_cancelled_title'.tr(),
      subtitle: 'booking_cancelled_subtitle'.tr(),
      color: colors.warning,
    );
  }

  Widget _buildCompleted(BuildContext context) {
    final colors = context.colors;
    return _neutralResolvedView(
      context,
      icon: Icons.check_circle_outline,
      title: 'booking_completed_title'.tr(),
      subtitle: '',
      color: colors.success,
    );
  }

  Widget _neutralResolvedView(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 26.h),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88.r,
                  height: 88.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 40.sp),
                ),
                SizedBox(height: 26.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19.sp,
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5.sp, height: 1.8, color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          _retryButton(context),
        ],
      ),
    );
  }

  Widget _retryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: () {
          context.read<BookingCubit>().retry();
          setState(() {
            _checkIn = null;
            _checkOut = null;
          });
          _loadAvailability();
        },
        child: Text(
          'booking_try_another_date'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
    );
  }

  Widget _summaryRow(AppSemanticColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5.sp, color: colors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.5.sp,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _rangeLabel(BookingEntity booking, String localeCode) {
    final format = DateFormat('d MMM', localeCode);
    return '${format.format(booking.checkIn)} – ${format.format(booking.checkOut)}';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = enabled ? colors.primary : colors.border;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(17.r),
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.4)),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final AppSemanticColors colors;
  final String label;

  const _Chip({required this.colors, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11.5.sp,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
