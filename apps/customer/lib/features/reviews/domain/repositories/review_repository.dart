import 'package:dartz/dartz.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/review_entity.dart';

abstract class ReviewRepository {
  /// ينشئ تقييماً جديداً — يفشل بمفتاح `submit_review_already_reviewed_error`
  /// لو [bookingId] له تقييم مسبقاً (قيد UNIQUE على `reviews.booking_id`
  /// بقاعدة البيانات، لا تكرار للتحقق بالعميل).
  ///
  /// [photoPaths] مسارات ملفات محلية (من image_picker) — تُرفع لـ
  /// Storage bucket `farm-media` ثم تُسجَّل بجدول `farm_media` المرتبط
  /// بالمزرعة نفسها؛ لا عمود/جدول مخصّص لصور التقييم موثّق بالمخطط
  /// الأصلي بعد (⚠️ فجوة مخطط — راجع توثيق `submitReview` بالتنفيذ).
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
  });
}
