import 'package:equatable/equatable.dart';

/// ⚠️ يطابق enum `booking_status` الموثّق بالمخطط بالضبط — لا توجد قيمة
/// "منتهي المهلة" منفصلة. انتهاء القفل الزمني حالة **مشتقة على العميل**
/// من مقارنة [BookingEntity.lockExpiresAt] بالوقت الحالي أثناء الحالة
/// pending، وليست حالة يقرّرها العميل نهائياً — القرار الرسمي يبقى عند
/// الخادم (pg_cron) عبر إعادة جلب الحجز.
enum BookingStatus { pending, confirmed, rejected, cancelled, completed }

class BookingEntity extends Equatable {
  final String id;
  final String farmId;
  final String farmName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double? totalPrice;
  final BookingStatus status;
  final DateTime? lockExpiresAt;

  /// ⚠️ لا يوجد عمود `rejection_reason` بمخطط `bookings` الموثّق بعد —
  /// يبقى دائماً null حتى تُضاف العمود بمايجريشن مستقبلي. نقطة التصحيح
  /// الوحيدة: `booking_model.dart` + المخطط نفسه.
  final String? rejectionReason;

  const BookingEntity({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.lockExpiresAt,
    this.rejectionReason,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  /// هل ما زالت المهلة الزمنية سارية بحسب ساعة الجهاز — مجرّد مؤشر
  /// واجهة، لا قرار نهائي (راجع توثيق [BookingStatus]).
  bool get lockStillActive {
    final expires = lockExpiresAt;
    if (expires == null) return false;
    return DateTime.now().isBefore(expires);
  }

  @override
  List<Object?> get props => [
    id,
    farmId,
    farmName,
    checkIn,
    checkOut,
    guests,
    totalPrice,
    status,
    lockExpiresAt,
    rejectionReason,
  ];
}
