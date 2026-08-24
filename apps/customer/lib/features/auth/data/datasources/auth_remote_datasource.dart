import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import 'package:mashwar_core/mashwar_core.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

bool _isEmail(String identifier) => _emailRegex.hasMatch(identifier);

@lazySingleton
class AuthRemoteDataSource {
  final SupabaseClient _client;

  const AuthRemoteDataSource(this._client);

  Future<UserModel> signUp({
    required String identifier,
    required String password,
    required String fullName,
  }) async {
    final isEmail = _isEmail(identifier);

    try {
      final response = await _client.auth.signUp(
        email: isEmail ? identifier : null,
        phone: isEmail ? null : identifier,
        password: password,
      );
      final authUser = response.user;
      if (authUser == null) {
        throw const ServerException('auth_error_signup_failed');
      }

      final profileData = {
        'id': authUser.id,
        'full_name': fullName,
        'phone': isEmail ? null : identifier,
        'role': UserRole.customer.name,
      };
      await _client.from(SupabaseTables.profiles).insert(profileData);

      return UserModel.fromMap(profileData, email: authUser.email);
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    } on PostgrestException catch (e, st) {
      appLogger.e('signUp: profile insert failed', error: e, stackTrace: st);
      throw const ServerException('auth_error_generic');
    }
  }

  Future<UserModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final isEmail = _isEmail(identifier);

    try {
      final response = await _client.auth.signInWithPassword(
        email: isEmail ? identifier : null,
        phone: isEmail ? null : identifier,
        password: password,
      );
      final authUser = response.user;
      if (authUser == null) {
        throw const ServerException('auth_error_signin_failed');
      }

      final profileRow = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', authUser.id)
          .single();

      return UserModel.fromMap(profileRow, email: authUser.email);
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    } on PostgrestException catch (e, st) {
      appLogger.e('signIn: profile fetch failed', error: e, stackTrace: st);
      throw const ServerException('auth_error_generic');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final profileRow = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', authUser.id)
          .single();

      return UserModel.fromMap(profileRow, email: authUser.email);
    } on PostgrestException catch (e, st) {
      appLogger.e('getCurrentUser: profile fetch failed', error: e, stackTrace: st);
      throw const ServerException('auth_error_generic');
    }
  }

  Future<void> requestPasswordReset(String identifier) async {
    final isEmail = _isEmail(identifier);

    try {
      if (isEmail) {
        await _client.auth.resetPasswordForEmail(identifier);
      } else {
        // shouldCreateUser: false — هذا استرجاع كلمة مرور لحساب موجود
        // مسبقاً، لا تسجيل حساب جديد؛ رقم غير مسجَّل يجب أن يفشل هنا لا
        // أن يُنشئ حساباً فارغاً بالخطأ.
        await _client.auth.signInWithOtp(phone: identifier, shouldCreateUser: false);
      }
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    }
  }

  Future<void> verifyPasswordResetCode(String identifier, String code) async {
    final isEmail = _isEmail(identifier);

    try {
      await _client.auth.verifyOTP(
        email: isEmail ? identifier : null,
        phone: isEmail ? null : identifier,
        token: code,
        type: isEmail ? OtpType.recovery : OtpType.sms,
      );
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw ServerException(_mapAuthErrorKey(e));
    }
  }

  /// يحوّل رسالة Supabase الخام (إنجليزية دائماً) إلى مفتاح ترجمة معروف
  /// بدل عرضها كما هي أو ترجمتها هنا مباشرة — طبقة الـdata تبقى بلا أي
  /// اعتمادية على Flutter/easy_localization؛ طبقة العرض هي من تستدعي
  /// `.tr()` على المفتاح المرجَع.
  String _mapAuthErrorKey(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'auth_error_invalid_credentials';
    }
    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already')) {
      return 'auth_error_email_taken';
    }
    if (message.contains('email not confirmed')) {
      return 'auth_error_email_not_confirmed';
    }
    if (message.contains('password') &&
        (message.contains('short') || message.contains('weak'))) {
      return 'auth_error_weak_password';
    }
    if (message.contains('token') &&
        (message.contains('expired') || message.contains('invalid'))) {
      return 'auth_error_invalid_code';
    }
    return 'auth_error_generic';
  }
}
