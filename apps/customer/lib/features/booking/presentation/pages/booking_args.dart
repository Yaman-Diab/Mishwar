/// وسيطة تنقل بيانات المزرعة من شاشة التفاصيل إلى شاشة الحجز — عقد
/// التنقّل نفسه صحيح فعلياً (هذا بالضبط ما يحتاجه تدفّق بحث/تفاصيل
/// حقيقي لاحقاً)، حتى لو مصدر البيانات حالياً تجريبي بانتظار ربط جدول
/// `farms` الفعلي.
class BookingArgs {
  final String farmId;
  final String farmName;
  final String location;
  final bool isVerified;
  final double pricePerDay;
  final int maxGuests;

  const BookingArgs({
    required this.farmId,
    required this.farmName,
    required this.location,
    required this.isVerified,
    required this.pricePerDay,
    required this.maxGuests,
  });
}
