import 'package:dartz/dartz.dart';

import 'package:mashwar_core/mashwar_core.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// [identifier] بريد إلكتروني أو رقم هاتف — يُحدَّد شكله تلقائياً
  /// بطبقة الـdata لتوجيهه لمعامل Supabase الصحيح (email أو phone).
  Future<Either<Failure, UserEntity>> signUp({
    required String identifier,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// يرسل رمز تحقق مكوّن من 6 أرقام لبريد/هاتف [identifier] لإعادة
  /// تعيين كلمة المرور.
  Future<Either<Failure, void>> requestPasswordReset({required String identifier});

  /// يتحقق من [code] المرسَل إلى [identifier]، وعند النجاح يُنشئ جلسة
  /// استعادة (recovery session) تسمح باستدعاء [updatePassword] بعده.
  Future<Either<Failure, void>> verifyPasswordResetCode({
    required String identifier,
    required String code,
  });

  /// يحدّث كلمة مرور المستخدم الحالي — يتطلب جلسة استعادة سارية من
  /// [verifyPasswordResetCode].
  Future<Either<Failure, void>> updatePassword({required String newPassword});
}
