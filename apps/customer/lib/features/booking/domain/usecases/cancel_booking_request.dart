import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/booking_repository.dart';

@injectable
class CancelBookingRequest implements UseCase<void, CancelBookingRequestParams> {
  final BookingRepository _repository;

  const CancelBookingRequest(this._repository);

  @override
  Future<Either<Failure, void>> call(CancelBookingRequestParams params) {
    return _repository.cancelBooking(params.bookingId);
  }
}

class CancelBookingRequestParams extends Equatable {
  final String bookingId;

  const CancelBookingRequestParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
