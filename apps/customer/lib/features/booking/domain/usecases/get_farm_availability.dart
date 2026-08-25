import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/availability_day_entity.dart';
import '../repositories/booking_repository.dart';

@injectable
class GetFarmAvailability implements UseCase<List<AvailabilityDayEntity>, GetFarmAvailabilityParams> {
  final BookingRepository _repository;

  const GetFarmAvailability(this._repository);

  @override
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    GetFarmAvailabilityParams params,
  ) {
    return _repository.getFarmAvailability(
      farmId: params.farmId,
      from: params.from,
      to: params.to,
    );
  }
}

class GetFarmAvailabilityParams extends Equatable {
  final String farmId;
  final DateTime from;
  final DateTime to;

  const GetFarmAvailabilityParams({
    required this.farmId,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [farmId, from, to];
}
