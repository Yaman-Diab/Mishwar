import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../cubit/submit_review_cubit.dart';
import '../cubit/submit_review_state.dart';
import '../widgets/star_rating_row.dart';
import 'submit_review_args.dart';

class _CriterionDef {
  final String key;
  final String labelKey;

  const _CriterionDef(this.key, this.labelKey);
}

const _allCriteria = [
  _CriterionDef('cleanliness', 'submit_review_criterion_cleanliness'),
  _CriterionDef('photo_accuracy', 'submit_review_criterion_photo_accuracy'),
  _CriterionDef('privacy', 'submit_review_criterion_privacy'),
  _CriterionDef('pool_quality', 'submit_review_criterion_pool_quality'),
  _CriterionDef('owner_conduct', 'submit_review_criterion_owner_conduct'),
];

class SubmitReviewPage extends StatelessWidget {
  final SubmitReviewArgs args;

  const SubmitReviewPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubmitReviewCubit>(),
      child: _SubmitReviewView(args: args),
    );
  }
}

class _SubmitReviewView extends StatefulWidget {
  final SubmitReviewArgs args;

  const _SubmitReviewView({required this.args});

  @override
  State<_SubmitReviewView> createState() => _SubmitReviewViewState();
}

class _SubmitReviewViewState extends State<_SubmitReviewView> {
  static const _maxPhotos = 6;

  late final List<_CriterionDef> _criteria = widget.args.hasPool
      ? _allCriteria
      : _allCriteria.where((c) => c.key != 'pool_quality').toList();

  final Map<String, int> _ratings = {};
  final _commentController = TextEditingController();
  final List<XFile> _photos = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int get _doneCount => _criteria.where((c) => (_ratings[c.key] ?? 0) > 0).length;

  bool get _ready => _doneCount == _criteria.length;

  void _rate(String key, int value) => setState(() => _ratings[key] = value);

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PhotoSourceSheet(colors: context.colors),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _photos.add(picked));
  }

  void _removePhoto(XFile photo) => setState(() => _photos.remove(photo));

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
          margin: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 96.h),
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  void _submit() {
    if (!_ready) {
      _showToast('submit_review_rate_all_error'.tr());
      return;
    }
    final comment = _commentController.text.trim();
    context.read<SubmitReviewCubit>().submit(
      bookingId: widget.args.bookingId,
      farmId: widget.args.farmId,
      cleanliness: _ratings['cleanliness']!,
      photoAccuracy: _ratings['photo_accuracy']!,
      privacy: _ratings['privacy']!,
      poolQuality: widget.args.hasPool ? _ratings['pool_quality'] : null,
      ownerConduct: _ratings['owner_conduct']!,
      comment: comment.isEmpty ? null : comment,
      photoPaths: _photos.map((p) => p.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<SubmitReviewCubit, SubmitReviewState>(
      listener: (context, state) {
        if (state.errorMessageKey != null) {
          _showToast(state.errorMessageKey!.tr());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: state.step == SubmitReviewStep.success
              ? _buildSuccess(context, state)
              : _buildForm(context, state, colors),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, SubmitReviewState state, AppSemanticColors colors) {
    final localeCode = context.locale.languageCode;
    final format = DateFormat('d MMM', localeCode);
    final dates = '${format.format(widget.args.checkIn)} – ${format.format(widget.args.checkOut)}';

    return Column(
      children: [
        _buildHeader(colors, dates),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
            children: [
              Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.075),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.check, color: colors.background, size: 12.sp),
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Text(
                        'submit_review_trust_note'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5.sp,
                          height: 1.75,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildProgress(colors),
              SizedBox(height: 16.h),
              ..._criteria.map((c) => _buildCriterionCard(colors, c)),
              _buildCommentSection(colors),
              _buildPhotosSection(colors),
            ],
          ),
        ),
        _buildSubmitBar(colors, state),
      ],
    );
  }

  Widget _buildHeader(AppSemanticColors colors, String dates) {
    return Container(
      padding: EdgeInsets.only(bottom: 22.h),
      decoration: BoxDecoration(color: colors.primary),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PositionedDirectional(
              top: -84.h,
              start: -46.w,
              child: Container(
                width: 230.r,
                height: 230.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [colors.background.withValues(alpha: 0.12), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(18.r),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: colors.background, size: 17.sp),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'submit_review_title'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          color: colors.background,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          width: 58.r,
                          height: 58.r,
                          color: colors.background.withValues(alpha: 0.14),
                        ),
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
                                fontSize: 15.sp,
                                color: colors.background,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '$dates · ${'booking_guests_count'.plural(widget.args.guests)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11.5.sp,
                                color: colors.background.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(AppSemanticColors colors) {
    final ready = _ready;
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: _doneCount / _criteria.length,
                minHeight: 5.h,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            ready
                ? 'submit_review_progress_ready'.tr()
                : 'submit_review_progress_partial'.tr(
                    namedArgs: {'done': '$_doneCount', 'total': '${_criteria.length}'},
                  ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              color: ready ? colors.primary : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionCard(AppSemanticColors colors, _CriterionDef criterion) {
    final value = _ratings[criterion.key] ?? 0;
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.fromLTRB(15.w, 13.h, 15.w, 11.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: value > 0 ? colors.accent.withValues(alpha: 0.32) : colors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                criterion.labelKey.tr(),
                style: TextStyle(fontSize: 13.5.sp, color: colors.textPrimary),
              ),
              if (value > 0)
                Text(
                  'submit_review_star_hint_$value'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5.sp,
                    color: value >= 4 ? colors.accent : colors.textSecondary,
                  ),
                ),
            ],
          ),
          StarRatingRow(value: value, onChanged: (n) => _rate(criterion.key, n)),
        ],
      ),
    );
  }

  Widget _buildCommentSection(AppSemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'submit_review_comment_label'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: colors.textPrimary,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _commentController,
                builder: (context, value, _) => Text(
                  'submit_review_comment_counter'.tr(namedArgs: {'count': '${value.text.length}'}),
                  style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _commentController,
            maxLength: 500,
            maxLines: 4,
            style: TextStyle(fontSize: 13.5.sp, color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'submit_review_comment_hint'.tr(),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(AppSemanticColors colors) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'submit_review_photos_label'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                _photos.isEmpty
                    ? 'submit_review_photos_optional'.tr()
                    : 'submit_review_photos_counter'.tr(
                        namedArgs: {'count': '${_photos.length}', 'max': '$_maxPhotos'},
                      ),
                style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (final photo in _photos)
                SizedBox(
                  width: 78.r,
                  height: 78.r,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(photo.path),
                          width: 78.r,
                          height: 78.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PositionedDirectional(
                        top: -6.h,
                        end: -6.w,
                        child: InkWell(
                          onTap: () => _removePhoto(photo),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 24.r,
                            height: 24.r,
                            decoration: BoxDecoration(
                              color: colors.textPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.background, width: 2),
                            ),
                            child: Icon(Icons.close, size: 11.sp, color: colors.background),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_photos.length < _maxPhotos)
                InkWell(
                  onTap: _addPhoto,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 78.r,
                    height: 78.r,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.055),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.42),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 19.sp, color: colors.primary),
                        SizedBox(height: 5.h),
                        Text(
                          'submit_review_add_photos'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 9.5.sp,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(AppSemanticColors colors, SubmitReviewState state) {
    final ready = _ready;
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
              onPressed: (ready && !state.submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                disabledBackgroundColor: colors.accent.withValues(alpha: 0.4),
              ),
              child: state.submitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          (state.statusMessageKey ?? 'submit_review_publishing').tr(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5.sp),
                        ),
                      ],
                    )
                  : Text(
                      'submit_review_submit_cta'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            ready
                ? 'submit_review_cta_hint_ready'.tr()
                : 'submit_review_cta_hint_incomplete'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, SubmitReviewState state) {
    final colors = context.colors;
    final review = state.result;
    if (review == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(26.w, 40.h, 26.w, 26.h),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 196.r,
                    height: 196.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 5.r),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 78.r,
                        height: 78.r,
                        child: CustomPaint(
                          painter: SealMarkPainter(
                            markColor: colors.primary,
                            veinColor: colors.background,
                            showRing: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'submit_review_success_title'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      height: 1.5,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.075),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            final filled = i < review.average.round();
                            return Icon(
                              filled ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 15.sp,
                              color: colors.accent,
                            );
                          }),
                        ),
                        SizedBox(width: 9.w),
                        Text(
                          '${review.average.toStringAsFixed(1)} · ${widget.args.farmName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: colors.primary,
                          ),
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
                  'submit_review_back_to_bookings'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  final AppSemanticColors colors;

  const _PhotoSourceSheet({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: colors.primary),
              title: Text('submit_review_photo_source_camera'.tr()),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            Divider(height: 1, color: colors.border),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colors.primary),
              title: Text('submit_review_photo_source_gallery'.tr()),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
