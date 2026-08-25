import 'package:dartz/dartz.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/availability_day_entity.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<AvailabilityDayEntity>>> getFarmAvailability({
    required String farmId,
    required DateTime from,
    required DateTime to,
  });

  /// ينفّذ دالة `request_booking` الذرية بقاعدة البيانات (قفل + تحقّق +
  /// إنشاء الحجز بمعاملة واحدة) — لا يوجد أي منطق قفل بالعميل، تماماً
  /// كما يفرض دليل البدء التقني.
  Future<Either<Failure, BookingEntity>> requestBooking({
    required String farmId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  });

  Future<Either<Failure, BookingEntity>> getBooking(String bookingId);

  Future<Either<Failure, void>> cancelBooking(String bookingId);

  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
}
