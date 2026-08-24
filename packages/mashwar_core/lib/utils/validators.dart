import 'package:easy_localization/easy_localization.dart';

class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static final RegExp _phoneRegex = RegExp(r'^09\d{8}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'validation_email_required'.tr();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'validation_email_invalid'.tr();
    }
    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'validation_phone_required'.tr();
    if (!_phoneRegex.hasMatch(trimmed)) {
      return 'validation_phone_invalid'.tr();
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'validation_password_required'.tr();
    if (value.length < 6) {
      return 'validation_password_too_short'.tr(namedArgs: {'min': '6'});
    }
    return null;
  }

  static String? required(String? value, {String? messageKey}) {
    if (value == null || value.trim().isEmpty) {
      return (messageKey ?? 'validation_field_required').tr();
    }
    return null;
  }
}
