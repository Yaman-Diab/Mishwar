import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.farmId,
    required super.cleanliness,
    required super.photoAccuracy,
    required super.privacy,
    required super.poolQuality,
    required super.ownerConduct,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      bookingId: map['booking_id'] as String,
      farmId: map['farm_id'] as String,
      cleanliness: map['cleanliness'] as int,
      photoAccuracy: map['photo_accuracy'] as int,
      privacy: map['privacy'] as int,
      poolQuality: map['pool_quality'] as int?,
      ownerConduct: map['owner_conduct'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
