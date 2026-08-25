import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  const ReviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ReviewEntity>> submitReview({
    required String bookingId,
    required String farmId,
    required int cleanliness,
    required int photoAccuracy,
    required int privacy,
    required int? poolQuality,
    required int ownerConduct,
    required String? comment,
    required List<String> photoPaths,
  }) async {
    try {
      final review = await _remoteDataSource.submitReview(
        bookingId: bookingId,
        farmId: farmId,
        cleanliness: cleanliness,
        photoAccuracy: photoAccuracy,
        privacy: privacy,
        poolQuality: poolQuality,
        ownerConduct: ownerConduct,
        comment: comment,
        photoPaths: photoPaths,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
