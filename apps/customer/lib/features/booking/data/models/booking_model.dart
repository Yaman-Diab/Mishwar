import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.farmId,
    required super.farmName,
    required super.checkIn,
    required super.checkOut,
    required super.guests,
    required super.totalPrice,
    required super.status,
    required super.lockExpiresAt,
    super.rejectionReason,
  });

  /// [map] قد يأتي من `.select()` بسيط (بلا اسم مزرعة) أو من
  /// `.select('*, farms(name)')` — نتعامل مع الحالتين لأن بعض النداءات
  /// (كإعادة الجلب بعد `request_booking`) لا تحتاج اسم المزرعة أصلاً.
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final farmRelation = map['farms'];
    final farmName = farmRelation is Map ? (farmRelation['name'] as String? ?? '') : '';

    return BookingModel(
      id: map['id'] as String,
      farmId: map['farm_id'] as String,
      farmName: farmName,
      checkIn: DateTime.parse(map['check_in'] as String),
      checkOut: DateTime.parse(map['check_out'] as String),
      guests: map['guests'] as int,
      totalPrice: (map['total_price'] as num?)?.toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      lockExpiresAt: map['lock_expires_at'] != null
          ? DateTime.parse(map['lock_expires_at'] as String)
          : null,
      rejectionReason: map['rejection_reason'] as String?,
    );
  }
}
