import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';

/// اعتماد عابر لحدود الميزة (my_bookings ← domain الخاص بـbooking) —
/// نفس الاستثناء المطبَّق بين Splash وOnboarding: الكيان والعقد نفسه
/// تبع ميزة الحجز، لا داعي لتكراره هنا فقط لعزل مصطنع.
@injectable
class GetMyBookings implements UseCase<List<BookingEntity>, NoParams> {
  final BookingRepository _repository;

  const GetMyBookings(this._repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(NoParams params) {
    return _repository.getMyBookings();
  }
}
