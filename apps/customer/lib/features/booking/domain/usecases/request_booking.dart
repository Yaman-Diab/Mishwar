import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

@injectable
class RequestBooking implements UseCase<BookingEntity, RequestBookingParams> {
  final BookingRepository _repository;

  const RequestBooking(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(RequestBookingParams params) {
    return _repository.requestBooking(
      farmId: params.farmId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guests: params.guests,
    );
  }
}

class RequestBookingParams extends Equatable {
  final String farmId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;

  const RequestBookingParams({
    required this.farmId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
  });

  @override
  List<Object?> get props => [farmId, checkIn, checkOut, guests];
}
