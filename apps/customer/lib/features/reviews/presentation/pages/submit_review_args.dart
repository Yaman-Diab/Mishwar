class SubmitReviewArgs {
  final String bookingId;
  final String farmId;
  final String farmName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  /// ⚠️ لا تدفّق بيانات مرافق حقيقي بين المزرعة وشاشة الحجز/التقييم
  /// بعد — نفترض وجود مسبح افتراضياً (يطابق العرض الحالي بكل الشاشات
  /// التجريبية الأخرى) لحين ربط `farms`/`amenities` فعلياً بمسار
  /// البحث → التفاصيل → الحجز.
  final bool hasPool;

  const SubmitReviewArgs({
    required this.bookingId,
    required this.farmId,
    required this.farmName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.hasPool = true,
  });
}
