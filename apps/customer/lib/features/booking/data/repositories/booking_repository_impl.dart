import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/entities/availability_day_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  const BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<AvailabilityDayEntity>>> getFarmAvailability({
    required String farmId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final days = await _remoteDataSource.getFarmAvailability(
        farmId: farmId,
        from: from,
        to: to,
      );
      return Right(days);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> requestBooking({
    required String farmId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    try {
      final booking = await _remoteDataSource.requestBooking(
        farmId: farmId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
      );
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId) async {
    try {
      final booking = await _remoteDataSource.getBooking(bookingId);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await _remoteDataSource.cancelBooking(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    try {
      final bookings = await _remoteDataSource.getMyBookings();
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
