import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

@injectable
class GetBookingStatus implements UseCase<BookingEntity, GetBookingStatusParams> {
  final BookingRepository _repository;

  const GetBookingStatus(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(GetBookingStatusParams params) {
    return _repository.getBooking(params.bookingId);
  }
}

class GetBookingStatusParams extends Equatable {
  final String bookingId;

  const GetBookingStatusParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
