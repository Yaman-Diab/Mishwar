import 'package:equatable/equatable.dart';

/// ⚠️ الحقول الخمسة مطابقة حرفياً لأعمدة جدول `reviews` الموثّق
/// (Dev_Kickoff_Guide) — `cleanliness/photo_accuracy/privacy/
/// pool_quality/owner_conduct`، كل واحد قيد 1-5 بقيد CHECK بقاعدة
/// البيانات نفسها.
class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String farmId;
  final int cleanliness;
  final int photoAccuracy;
  final int privacy;
  final int? poolQuality;
  final int ownerConduct;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.farmId,
    required this.cleanliness,
    required this.photoAccuracy,
    required this.privacy,
    required this.poolQuality,
    required this.ownerConduct,
    required this.comment,
    required this.createdAt,
  });

  double get average {
    final scores = [
      cleanliness,
      photoAccuracy,
      privacy,
      ?poolQuality,
      ownerConduct,
    ];
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    farmId,
    cleanliness,
    photoAccuracy,
    privacy,
    poolQuality,
    ownerConduct,
    comment,
    createdAt,
  ];
}
