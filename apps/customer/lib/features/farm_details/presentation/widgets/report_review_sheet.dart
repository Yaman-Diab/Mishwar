import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashwar_core/mashwar_core.dart';

enum ReportReason { abusive, falseInfo, inappropriate, other }

String _reasonKey(ReportReason reason) => switch (reason) {
  ReportReason.abusive => 'farm_details_report_reason_abusive',
  ReportReason.falseInfo => 'farm_details_report_reason_false_info',
  ReportReason.inappropriate => 'farm_details_report_reason_inappropriate',
  ReportReason.other => 'farm_details_report_reason_other',
};

class ReportReviewSheet extends StatefulWidget {
  final String reviewerName;
  final Future<void> Function(ReportReason reason, String note) onSubmit;

  const ReportReviewSheet({
    super.key,
    required this.reviewerName,
    required this.onSubmit,
  });

  @override
  State<ReportReviewSheet> createState() => _ReportReviewSheetState();
}

class _ReportReviewSheetState extends State<ReportReviewSheet> {
  ReportReason? _reason;
  final _noteController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null || _sending) return;
    setState(() => _sending = true);
    await widget.onSubmit(_reason!, _noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canSubmit = _reason != null && !_sending;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 26.h),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 18.h),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'farm_details_report_review_title'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.5.sp,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'farm_details_report_review_subtitle'.tr(
                            namedArgs: {'name': widget.reviewerName},
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.7,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 15.sp, color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              ...ReportReason.values.map(
                (reason) => Padding(
                  padding: EdgeInsets.only(bottom: 9.h),
                  child: _ReasonTile(
                    colors: colors,
                    label: _reasonKey(reason).tr(),
                    selected: _reason == reason,
                    onTap: () => setState(() => _reason = reason),
                  ),
                ),
              ),
              TextField(
                controller: _noteController,
                maxLength: 300,
                maxLines: 3,
                style: TextStyle(fontSize: 13.sp, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'farm_details_report_note_hint'.tr(),
                  counterText: '',
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14.sp, color: colors.textSecondary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'farm_details_report_note_info'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.7,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(disabledBackgroundColor: colors.border),
                  child: _sending
                      ? SizedBox(
                          width: 19.w,
                          height: 19.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'farm_details_report_submit'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final AppSemanticColors colors;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.colors,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.075) : colors.surface,
          border: Border.all(color: selected ? colors.primary : colors.border, width: 1.4),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.border,
                  width: 1.8,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                    )
                  : null,
            ),
            SizedBox(width: 11.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5.sp,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
