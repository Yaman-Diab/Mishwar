import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../../../booking/presentation/pages/booking_args.dart';
import '../../../favorites/domain/usecases/add_favorite.dart';
import '../../../favorites/domain/usecases/remove_favorite.dart';
import '../models/farm_details_sample_data.dart';
import '../widgets/farm_amenity_icons.dart';
import '../widgets/report_review_sheet.dart';
import '../widgets/verified_info_sheet.dart';
import 'photo_viewer_page.dart';

/// ⚠️ تعرض بيانات تجريبية ثابتة (`FarmDetailsSampleData`) لا مزرعة
/// حقيقية — لا يوجد بعد تدفّق بحث/قائمة يفتح هذه الشاشة بمعرّف مزرعة
/// فعلي، ولا جدول `farms` مربوط. الحالة التفاعلية (توسيع الوصف، فهرس
/// المعرض، الإبلاغ) محلية بالصفحة عمداً لعدم وجود عملية Backend حقيقية
/// تبرر Cubit بهذه المرحلة؛ ستُستبدل حين يُربط بحث/تفاصيل مزرعة فعلياً
/// بجدول Supabase. **الاستثناء**: تبديل المفضلة يستدعي usecases حقيقية
/// (نفس مسار ميزة favorites، لا تكرار) — سيفشل حالياً بخطأ مفتاح أجنبي
/// لأن معرّف المزرعة تجريبي، لذا نتراجع محلياً بصمت دون توست خطأ إضافي.
class FarmDetailsPage extends StatefulWidget {
  const FarmDetailsPage({super.key});

  @override
  State<FarmDetailsPage> createState() => _FarmDetailsPageState();
}

class _FarmDetailsPageState extends State<FarmDetailsPage> {
  static const _photoCount = 3;

  final _galleryController = PageController();
  int _photoIndex = 0;
  bool _isFavorite = false;
  bool _descriptionExpanded = false;

  /// ⚠️ محلية فقط — لا جدول `review_reports` موثّق بأي مخطط بعد،
  /// وتقييمات هذه الشاشة أصلاً تجريبية (راجع تعليق الملف بالأعلى).
  /// تُصفَّر عند إعادة تشغيل التطبيق، لا تُحفَظ فعلياً.
  final Set<String> _reportedReviewIds = {};

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerPage(initialIndex: index, photoCount: _photoCount),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final next = !_isFavorite;
    setState(() => _isFavorite = next);
    _showToast(
      next ? 'farm_details_favorite_added'.tr() : 'farm_details_favorite_removed'.tr(),
    );

    const farmId = FarmDetailsSampleData.demoFarmId;
    final result = next
        ? await getIt<AddFavorite>()(const AddFavoriteParams(farmId: farmId))
        : await getIt<RemoveFavorite>()(const RemoveFavoriteParams(farmId: farmId));

    // فشل متوقَّع حالياً (معرّف مزرعة تجريبي لا صف حقيقي له) — نتراجع
    // بصمت عن الحالة المتفائلة بدل إزعاج المستخدم بتوست خطأ متكرر على
    // بيانات تجريبية؛ المسار نفسه صحيح وسيعمل فور ربط مزرعة حقيقية.
    if (!mounted) return;
    result.fold((failure) => setState(() => _isFavorite = !next), (_) {});
  }

  void _share() {
    Clipboard.setData(const ClipboardData(text: 'https://mishwar.app/farms/dar-al-yasmin'));
    _showToast('farm_details_link_copied'.tr());
  }

  void _openReportSheet(SampleReview review) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ReportReviewSheet(
        reviewerName: review.name,
        onSubmit: (reason, note) async {
          final navigator = Navigator.of(sheetContext);
          // محاكاة إرسال قصيرة لتجربة استخدام متماسكة فقط — لا نداء
          // شبكة حقيقي (لا جدول تقارير موثّق، والتقييم نفسه تجريبي).
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          navigator.pop();
          setState(() => _reportedReviewIds.add(review.id));
          _showToast('farm_details_report_success_toast'.tr());
        },
      ),
    );
  }

  void _bookNow() {
    final data = FarmDetailsSampleData.forLocale(context.locale);
    context.push(
      '/booking',
      extra: BookingArgs(
        farmId: FarmDetailsSampleData.demoFarmId,
        farmName: data.name,
        location: data.location,
        isVerified: true,
        pricePerDay: data.pricePerDayRaw,
        maxGuests: data.maxGuests,
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
          margin: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 96.h),
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  void _openVerifiedSheet(String verifiedDate) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => VerifiedInfoSheet(verifiedDate: verifiedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = FarmDetailsSampleData.forLocale(context.locale);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 325.h,
            collapsedHeight: 260.h,
            pinned: true,
            elevation: 0,
            backgroundColor: colors.border,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(background: _buildGallery(colors, data)),
          ),
          SliverToBoxAdapter(child: _buildTitleBlock(colors, data)),
          SliverToBoxAdapter(child: _buildAmenities(colors, data)),
          SliverToBoxAdapter(child: _buildDescription(colors, data)),
          SliverToBoxAdapter(child: _buildGuestPhotos(colors, data)),
          SliverToBoxAdapter(child: _buildReviews(colors, data)),
          SliverToBoxAdapter(child: SizedBox(height: 26.h)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(colors, data),
    );
  }

  Widget _buildGallery(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: colors.border),
        PageView.builder(
          controller: _galleryController,
          itemCount: _photoCount,
          onPageChanged: (i) => setState(() => _photoIndex = i),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openViewer(index),
              child: ImagePlaceholder(label: '${index + 1} / $_photoCount'),
            );
          },
        ),
        PositionedDirectional(
          top: 52.h,
          start: 16.w,
          end: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassCircleButton(
                onTap: () => Navigator.of(context).maybePop(),
                child: const BackButtonIcon(),
              ),
              Row(
                children: [
                  _GlassCircleButton(
                    onTap: _share,
                    child: const Icon(Icons.ios_share_outlined, size: 18),
                  ),
                  SizedBox(width: 9.w),
                  _GlassCircleButton(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 19,
                      color: _isFavorite ? colors.accent : const Color(0xFF1B2620),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 26.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_photoCount, (i) {
              final active = i == _photoIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: active ? 20.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: active
                      ? colors.background
                      : colors.background.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: Material(
            color: colors.background,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(18.r),
            ).resolve(Directionality.of(context)),
            child: InkWell(
              onTap: () => _openVerifiedSheet(data.verifiedDate),
              borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(18.r))
                  .resolve(Directionality.of(context)),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 9.h, 14.w, 11.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.check, color: colors.background, size: 13.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'farm_details_verified_badge'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.info_outline, size: 13.sp, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBlock(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 23.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15.sp, color: colors.textSecondary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  data.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              border: BorderDirectional(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          data.price,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 26.sp,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          data.priceUnit,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      data.priceNote,
                      style: TextStyle(fontSize: 12.sp, color: colors.textSecondary),
                    ),
                  ],
                ),
                _TrustScoreBadge(colors: colors, score: data.trustScore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'farm_details_amenities_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.5.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.amenities.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final amenity = data.amenities[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26.r,
                    height: 26.r,
                    child: CustomPaint(
                      painter: AmenityIconPainter(type: amenity.type, color: colors.primary),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    amenity.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5.sp,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'farm_details_about_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.5.sp,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            data.description,
            maxLines: _descriptionExpanded ? null : 4,
            overflow: _descriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5.sp, height: 1.95, color: colors.textSecondary),
          ),
          TextButton(
            onPressed: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.only(top: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: AlignmentDirectional.centerStart,
            ),
            child: Text(
              _descriptionExpanded
                  ? 'farm_details_show_less'.tr()
                  : 'farm_details_show_more'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestPhotos(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'farm_details_guest_photos_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5.sp,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'farm_details_photo_count'.tr(namedArgs: {'count': '${data.guestPhotoCount}'}),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 96.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              itemCount: 4,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (context, index) => SizedBox(
                width: 118.w,
                child: ImagePlaceholder(label: '${index + 1}', borderRadius: 14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'farm_details_reviews_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5.sp,
                    color: colors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 17.sp, color: colors.accent),
                    SizedBox(width: 4.w),
                    Text(
                      data.rating,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'farm_details_review_count'.tr(
                        namedArgs: {'count': '${data.reviewCount}'},
                      ),
                      style: TextStyle(fontSize: 12.sp, color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              children: data.reviewCriteria
                  .map((c) => _CriterionBar(colors: colors, criterion: c))
                  .toList(),
            ),
            Container(height: 1, color: colors.border, margin: EdgeInsets.symmetric(vertical: 16.h)),
            ...data.reviews.map(
              (r) => _ReviewTile(
                colors: colors,
                review: r,
                isReported: _reportedReviewIds.contains(r.id),
                onReport: () => _openReportSheet(r),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: null,
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h)),
                child: Text(
                  'farm_details_show_all_reviews'.tr(
                    namedArgs: {'count': '${data.reviewCount}'},
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppSemanticColors colors, FarmDetailsSampleData data) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: BorderDirectional(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.price,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17.sp,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  data.priceUnit,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5.sp,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: SizedBox(
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _bookNow,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.r),
                    ),
                  ),
                  child: Text(
                    'farm_details_book_now'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassCircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: const Color(0xFFFAF6EE).withValues(alpha: 0.86),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: IconTheme(
                data: const IconThemeData(color: Color(0xFF1B2620)),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustScoreBadge extends StatelessWidget {
  final AppSemanticColors colors;
  final int score;

  const _TrustScoreBadge({required this.colors, required this.score});

  @override
  Widget build(BuildContext context) {
    final high = score >= 70;
    final bg = high ? colors.success.withValues(alpha: 0.18) : colors.secondary;
    final ring = high ? colors.success.withValues(alpha: 0.45) : colors.border;
    final text = colors.textPrimary;

    return Column(
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: text),
              ),
              Text(
                '/ 100',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 8.sp,
                  color: text.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          'farm_details_trust_score_label'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10.5.sp,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CriterionBar extends StatelessWidget {
  final AppSemanticColors colors;
  final SampleReviewCriterion criterion;

  const _CriterionBar({required this.colors, required this.criterion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 11.h),
      child: Row(
        children: [
          SizedBox(
            width: 88.w,
            child: Text(
              criterion.labelKey.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: criterion.fraction,
                minHeight: 5.h,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 24.w,
            child: Text(
              criterion.score,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.5.sp,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final AppSemanticColors colors;
  final SampleReview review;
  final bool isReported;
  final VoidCallback onReport;

  const _ReviewTile({
    required this.colors,
    required this.review,
    required this.isReported,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: BorderDirectional(bottom: BorderSide(color: colors.border.withValues(alpha: 0.6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(color: colors.secondary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  review.initial,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: colors.primary,
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${review.date} · ${'farm_details_verified_visit'.tr()}',
                      style: TextStyle(fontSize: 10.5.sp, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.star_rounded, size: 13.sp, color: colors.accent),
              SizedBox(width: 3.w),
              Text(
                review.stars,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5.sp,
                  color: colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: isReported ? null : onReport,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28.r, minHeight: 28.r),
                iconSize: 14.sp,
                icon: Icon(
                  Icons.flag_outlined,
                  color: isReported ? colors.border : colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          Text(
            review.text,
            style: TextStyle(fontSize: 12.5.sp, height: 1.85, color: colors.textSecondary),
          ),
          if (isReported) ...[
            SizedBox(height: 9.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 12.sp, color: colors.textSecondary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'farm_details_report_pending_chip'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
