import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/review_model.dart';

@lazySingleton
class ReviewRemoteDataSource {
  static const _storageBucket = 'farm-media';

  final SupabaseClient _client;

  const ReviewRemoteDataSource(this._client);

  Future<ReviewModel> submitReview({
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
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ServerException('submit_review_error_generic');
    }

    final ReviewModel review;
    try {
      final row = await _client
          .from(SupabaseTables.reviews)
          .insert({
            'booking_id': bookingId,
            'farm_id': farmId,
            'customer_id': userId,
            'cleanliness': cleanliness,
            'photo_accuracy': photoAccuracy,
            'privacy': privacy,
            'pool_quality': poolQuality,
            'owner_conduct': ownerConduct,
            'comment': comment,
          })
          .select()
          .single();
      review = ReviewModel.fromMap(row);
    } on PostgrestException catch (e, st) {
      // 23505 = unique_violation — قيد UNIQUE على reviews.booking_id،
      // يعني تقييماً سابقاً موجوداً فعلاً لهذا الحجز.
      if (e.code == '23505') {
        throw const ServerException('submit_review_already_reviewed_error');
      }
      appLogger.e('submitReview: insert failed', error: e, stackTrace: st);
      throw const ServerException('submit_review_error_generic');
    }

    if (photoPaths.isNotEmpty) {
      await _uploadPhotos(farmId: farmId, reviewId: review.id, photoPaths: photoPaths);
    }

    return review;
  }

  /// ⚠️ لا عمود/جدول مخصّص لصور التقييم موثّق بالمخطط الأصلي — نرفع
  /// الصور لنفس Storage bucket المخصَّص لصور المزرعة (`farm-media` حسب
  /// Dev_Kickoff_Guide) ونسجّلها بجدول `farm_media` المرتبط بالمزرعة،
  /// وهو نفس الجدول الذي يُفترض أن تُقرأ منه صور "الزوار" بصفحة تفاصيل
  /// المزرعة لاحقاً. نقطة التصحيح لو أُضيف جدول/عمود مخصّص مستقبلاً.
  Future<void> _uploadPhotos({
    required String farmId,
    required String reviewId,
    required List<String> photoPaths,
  }) async {
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final storagePath = 'reviews/$reviewId/$i.jpg';

      try {
        await _client.storage.from(_storageBucket).upload(storagePath, file);
        final publicUrl = _client.storage.from(_storageBucket).getPublicUrl(storagePath);

        await _client.from(SupabaseTables.farmMedia).insert({
          'farm_id': farmId,
          'url': publicUrl,
          'media_type': 'image',
        });
      } catch (e, st) {
        // فشل رفع صورة واحدة ما لازم يُسقط التقييم كله — التقييم نفسه
        // نجح فعلاً بقاعدة البيانات، فقط الصورة هاي لم تُرفع.
        appLogger.e('submitReview: photo upload failed for $storagePath', error: e, stackTrace: st);
      }
    }
  }
}
