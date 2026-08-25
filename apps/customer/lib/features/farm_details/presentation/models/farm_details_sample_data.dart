import 'package:flutter/widgets.dart';

import '../widgets/farm_amenity_icons.dart';

/// ⚠️ بيانات تجريبية ثابتة — بانتظار ربط فعلي بجدولَي `farms`/`reviews`
/// على Supabase (نقطة التصحيح الوحيدة: هذا الملف بالكامل). لا تُمرَّر
/// عبر ملفات الترجمة `assets/translations/*.json` عمداً: تلك الملفات
/// تمثّل مفردات الواجهة الدائمة، لا محتوى تجريبياً سيُستبدَل بالكامل
/// ببيانات حقيقية لاحقاً — لذا نوفّر نسختين (عربي/إنكليزي) هنا مباشرة
/// فقط لضمان شاشة متّسقة عند اختبار الواجهة الإنكليزية، لا كإدخال دائم
/// بمعجم الترجمة.
class SampleAmenity {
  final AmenityType type;
  final String label;

  const SampleAmenity({required this.type, required this.label});
}

class SampleReviewCriterion {
  final String labelKey;
  final String score;
  final double fraction;

  const SampleReviewCriterion({
    required this.labelKey,
    required this.score,
    required this.fraction,
  });
}

class SampleReview {
  final String id;
  final String initial;
  final String name;
  final String date;
  final String stars;
  final String text;

  const SampleReview({
    required this.id,
    required this.initial,
    required this.name,
    required this.date,
    required this.stars,
    required this.text,
  });
}

class FarmDetailsSampleData {
  /// ⚠️ معرّف وهمي ثابت — لا صف حقيقي بجدول `farms` بهذا الـid. كافٍ
  /// لاختبار مسار التنقّل نحو شاشة الحجز، لكن استدعاء `request_booking`
  /// الفعلي سيفشل بخطأ مفتاح أجنبي حتى يُربط بحث/تفاصيل مزرعة حقيقي.
  static const String demoFarmId = '00000000-0000-0000-0000-000000000001';

  final String name;
  final String location;
  final String price;
  final double pricePerDayRaw;
  final int maxGuests;
  final String priceUnit;
  final String priceNote;
  final int trustScore;
  final String description;
  final List<SampleAmenity> amenities;
  final int guestPhotoCount;
  final String rating;
  final int reviewCount;
  final String verifiedDate;
  final List<SampleReviewCriterion> reviewCriteria;
  final List<SampleReview> reviews;

  const FarmDetailsSampleData({
    required this.name,
    required this.location,
    required this.price,
    required this.pricePerDayRaw,
    required this.maxGuests,
    required this.priceUnit,
    required this.priceNote,
    required this.trustScore,
    required this.description,
    required this.amenities,
    required this.guestPhotoCount,
    required this.rating,
    required this.reviewCount,
    required this.verifiedDate,
    required this.reviewCriteria,
    required this.reviews,
  });

  static FarmDetailsSampleData forLocale(Locale locale) {
    return locale.languageCode == 'en' ? _en : _ar;
  }

  static const List<SampleReviewCriterion> _criteria = [
    SampleReviewCriterion(labelKey: 'review_criterion_cleanliness', score: '4.8', fraction: 0.96),
    SampleReviewCriterion(labelKey: 'review_criterion_photo_match', score: '4.9', fraction: 0.98),
    SampleReviewCriterion(labelKey: 'review_criterion_privacy', score: '4.7', fraction: 0.94),
    SampleReviewCriterion(labelKey: 'review_criterion_pool_quality', score: '4.3', fraction: 0.86),
    SampleReviewCriterion(labelKey: 'review_criterion_owner_conduct', score: '4.6', fraction: 0.92),
  ];

  static const _ar = FarmDetailsSampleData(
    name: 'مزرعة دار الياسمين',
    location: 'ريف دمشق — قطنا · ٢٤ كم عن دمشق',
    price: '٣٥٠٬٠٠٠',
    pricePerDayRaw: 350000,
    maxGuests: 14,
    priceUnit: 'ل.س / اليوم',
    priceNote: 'يشمل المسبح والمرافق كلها',
    trustScore: 82,
    description:
        'مزرعة عائلية بقطنا على مساحة دونمين، محاطة بأشجار الزيتون والمشمش. '
        'المسبح منفصل عن جلسة الشاي، والخصوصية كاملة — ما في أي مزرعة '
        'مجاورة تشرف عليها. الجلسة الخارجية تتسع لـ١٤ شخص، والشواية جاهزة '
        'مع الفحم. الطريق معبّد كامل حتى باب المزرعة، والمولّدة تشتغل '
        'تلقائياً عند انقطاع الكهرباء. مناسبة للعائلات والتجمعات الصغيرة، '
        'وممنوع الحفلات الصاخبة بعد منتصف الليل احتراماً للجوار.',
    amenities: [
      SampleAmenity(type: AmenityType.pool, label: 'مسبح'),
      SampleAmenity(type: AmenityType.bbq, label: 'شواية'),
      SampleAmenity(type: AmenityType.kitchen, label: 'مطبخ'),
      SampleAmenity(type: AmenityType.heating, label: 'تدفئة'),
      SampleAmenity(type: AmenityType.ac, label: 'تكييف'),
      SampleAmenity(type: AmenityType.playground, label: 'ملعب'),
      SampleAmenity(type: AmenityType.bedrooms, label: 'غرف نوم ٣'),
      SampleAmenity(type: AmenityType.bathrooms, label: 'حمّامان'),
    ],
    guestPhotoCount: 12,
    rating: '٤٫٦',
    reviewCount: 28,
    verifiedDate: '١٤ آب ٢٠٢٦',
    reviewCriteria: _criteria,
    reviews: [
      SampleReview(
        id: 'rv1',
        initial: 'ل',
        name: 'لينا ح.',
        date: '١٠ آب ٢٠٢٦',
        stars: '٥٫٠',
        text: 'المكان مطابق تماماً للصور، والخصوصية كاملة فعلاً. المسبح كان '
            'نظيف والمولّدة اشتغلت لحالها وقت القطع.',
      ),
      SampleReview(
        id: 'rv2',
        initial: 'ع',
        name: 'عمر د.',
        date: '٢ آب ٢٠٢٦',
        stars: '٤٫٥',
        text: 'قعدة العائلة كانت مريحة، والشواية جاهزة مع الفحم. الطريق '
            'معبّد كامل. بس المسبح بيصير باردة عالمسا.',
      ),
    ],
  );

  static const _en = FarmDetailsSampleData(
    name: 'Dar Al-Yasmin Farm',
    location: 'Rural Damascus — Qatana · 24 km from Damascus',
    price: '350,000',
    pricePerDayRaw: 350000,
    maxGuests: 14,
    priceUnit: 'SYP / day',
    priceNote: 'Includes the pool and all amenities',
    trustScore: 82,
    description:
        'A family farm in Qatana on two dunams, surrounded by olive and '
        'apricot trees. The pool is separate from the tea seating area, '
        'and privacy is complete — no neighboring farm overlooks it. The '
        'outdoor seating fits 14 people, and the grill is ready with '
        'charcoal. The road is fully paved up to the farm gate, and the '
        'generator kicks in automatically during power cuts. Suitable for '
        'families and small gatherings; loud parties after midnight are '
        'not allowed out of respect for the neighbors.',
    amenities: [
      SampleAmenity(type: AmenityType.pool, label: 'Pool'),
      SampleAmenity(type: AmenityType.bbq, label: 'BBQ'),
      SampleAmenity(type: AmenityType.kitchen, label: 'Kitchen'),
      SampleAmenity(type: AmenityType.heating, label: 'Heating'),
      SampleAmenity(type: AmenityType.ac, label: 'A/C'),
      SampleAmenity(type: AmenityType.playground, label: 'Playground'),
      SampleAmenity(type: AmenityType.bedrooms, label: '3 bedrooms'),
      SampleAmenity(type: AmenityType.bathrooms, label: '2 bathrooms'),
    ],
    guestPhotoCount: 12,
    rating: '4.6',
    reviewCount: 28,
    verifiedDate: 'Aug 14, 2026',
    reviewCriteria: _criteria,
    reviews: [
      SampleReview(
        id: 'rv1',
        initial: 'L',
        name: 'Lina H.',
        date: 'Aug 10, 2026',
        stars: '5.0',
        text: 'The place matched the photos exactly, and privacy was '
            'complete. The pool was clean and the generator kicked in on '
            'its own during the outage.',
      ),
      SampleReview(
        id: 'rv2',
        initial: 'O',
        name: 'Omar D.',
        date: 'Aug 2, 2026',
        stars: '4.5',
        text: 'The family gathering was comfortable, and the grill was '
            'ready with charcoal. The road was fully paved. The pool does '
            'get a bit cold in the evening though.',
      ),
    ],
  );
}
