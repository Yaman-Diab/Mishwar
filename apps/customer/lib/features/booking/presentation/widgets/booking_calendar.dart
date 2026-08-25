import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

/// تقويم شهري بسيط لاختيار مدة الحجز — يعرض الشهر الحقيقي الحالي
/// (لا شهراً ثابتاً كالتصميم)، ويمنع اختيار أي يوم ماضٍ إضافة لمنع
/// الأيام المحجوزة/المغلقة.
class BookingCalendar extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final Set<DateTime> unavailableDays;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const BookingCalendar({
    super.key,
    required this.visibleMonth,
    required this.checkIn,
    required this.checkOut,
    required this.unavailableDays,
    required this.onDayTap,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  bool _isPast(DateTime day) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return day.isBefore(todayOnly);
  }

  bool _isUnavailable(DateTime day) {
    return unavailableDays.contains(DateTime(day.year, day.month, day.day));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = context.locale.toString();
    final firstWeekday = visibleMonth.weekday % 7; // الأحد = 0
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final today = DateTime.now();
    final canGoPrev = DateTime(visibleMonth.year, visibleMonth.month + 1, 0)
        .isAfter(DateTime(today.year, today.month, today.day));

    final weekdayLabels = List.generate(7, (i) {
      // 2023-01-01 كان أحداً — نستخدمها كمرجع ثابت لأسماء أيام الأسبوع.
      final sample = DateTime(2023, 1, 1 + i);
      return DateFormat.E(locale).format(sample);
    });

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.chevron_right,
                enabled: canGoPrev,
                onTap: onPrevMonth,
              ),
              Text(
                DateFormat.yMMMM(locale).format(visibleMonth),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5.sp,
                  color: colors.textPrimary,
                ),
              ),
              _NavButton(icon: Icons.chevron_left, enabled: true, onTap: onNextMonth),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: weekdayLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 4.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();

              final dayNum = index - firstWeekday + 1;
              final day = DateTime(visibleMonth.year, visibleMonth.month, dayNum);
              final disabled = _isPast(day) || _isUnavailable(day);
              final isStart = checkIn != null && _sameDate(day, checkIn!);
              final isEnd = checkOut != null && _sameDate(day, checkOut!);
              final inRange = checkIn != null &&
                  checkOut != null &&
                  day.isAfter(checkIn!) &&
                  day.isBefore(checkOut!);

              final Color bg;
              final Color fg;
              final BorderRadius radius;
              if (isStart || isEnd) {
                bg = colors.primary;
                fg = colors.background;
                radius = BorderRadius.circular(13.r);
              } else if (inRange) {
                bg = colors.primary.withValues(alpha: 0.13);
                fg = colors.textPrimary;
                radius = BorderRadius.circular(8.r);
              } else if (disabled) {
                bg = _isUnavailable(day) ? colors.border : Colors.transparent;
                fg = colors.textSecondary.withValues(alpha: 0.6);
                radius = BorderRadius.circular(12.r);
              } else {
                bg = Colors.transparent;
                fg = colors.textPrimary;
                radius = BorderRadius.circular(12.r);
              }

              return Padding(
                padding: EdgeInsets.all(1.5.w),
                child: Material(
                  color: bg,
                  borderRadius: radius,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: disabled ? null : () => onDayTap(day),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontWeight: (isStart || isEnd || inRange)
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13.5.sp,
                              color: fg,
                            ),
                          ),
                          if (_isUnavailable(day) && !isStart && !isEnd)
                            Container(height: 1.2, width: 18.w, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              border: BorderDirectional(top: BorderSide(color: colors.border.withValues(alpha: 0.6))),
            ),
            child: Row(
              children: [
                _LegendDot(color: colors.primary, label: 'booking_legend_selected'.tr()),
                SizedBox(width: 14.w),
                _LegendDot(color: colors.border, label: 'booking_legend_unavailable'.tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.07),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11.r,
          height: 11.r,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.r)),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.5.sp, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
