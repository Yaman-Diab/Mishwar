import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

@injectable
class SubmitReview implements UseCase<ReviewEntity, SubmitReviewParams> {
  final ReviewRepository _repository;

  const SubmitReview(this._repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(SubmitReviewParams params) {
    return _repository.submitReview(
      bookingId: params.bookingId,
      farmId: params.farmId,
      cleanliness: params.cleanliness,
      photoAccuracy: params.photoAccuracy,
      privacy: params.privacy,
      poolQuality: params.poolQuality,
      ownerConduct: params.ownerConduct,
      comment: params.comment,
      photoPaths: params.photoPaths,
    );
  }
}

class SubmitReviewParams extends Equatable {
  final String bookingId;
  final String farmId;
  final int cleanliness;
  final int photoAccuracy;
  final int privacy;
  final int? poolQuality;
  final int ownerConduct;
  final String? comment;
  final List<String> photoPaths;

  const SubmitReviewParams({
    required this.bookingId,
    required this.farmId,
    required this.cleanliness,
    required this.photoAccuracy,
    required this.privacy,
    required this.poolQuality,
    required this.ownerConduct,
    required this.comment,
    required this.photoPaths,
  });

  @override
  List<Object?> get props => [
    bookingId,
    farmId,
    cleanliness,
    photoAccuracy,
    privacy,
    poolQuality,
    ownerConduct,
    comment,
    photoPaths,
  ];
}
