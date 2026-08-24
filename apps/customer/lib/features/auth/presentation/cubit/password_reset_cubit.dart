import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/request_password_reset.dart';
import '../../domain/usecases/update_password.dart';
import '../../domain/usecases/verify_password_reset_code.dart';
import 'password_reset_state.dart';

@injectable
class PasswordResetCubit extends Cubit<PasswordResetState> {
  final RequestPasswordReset _requestPasswordReset;
  final VerifyPasswordResetCode _verifyPasswordResetCode;
  final UpdatePassword _updatePassword;

  PasswordResetCubit(
    this._requestPasswordReset,
    this._verifyPasswordResetCode,
    this._updatePassword,
  ) : super(const PasswordResetState());

  Future<void> sendCode(String identifier) async {
    emit(state.copyWith(isLoading: true, errorMessageKey: null));
    final result = await _requestPasswordReset(
      RequestPasswordResetParams(identifier: identifier),
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessageKey: failure.message)),
      (_) => emit(
        state.copyWith(
          isLoading: false,
          step: PasswordResetStep.code,
          identifier: identifier,
        ),
      ),
    );
  }

  /// نفس منطق [sendCode] لكن بلا تغيير الخطوة — الهوية محفوظة أصلاً
  /// بالحالة من إرسال الرمز الأول.
  Future<void> resendCode() async {
    emit(state.copyWith(isLoading: true, errorMessageKey: null));
    final result = await _requestPasswordReset(
      RequestPasswordResetParams(identifier: state.identifier),
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessageKey: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> verifyCode(String code) async {
    emit(state.copyWith(isLoading: true, errorMessageKey: null));
    final result = await _verifyPasswordResetCode(
      VerifyPasswordResetCodeParams(identifier: state.identifier, code: code),
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessageKey: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, step: PasswordResetStep.password)),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    emit(state.copyWith(isLoading: true, errorMessageKey: null));
    final result = await _updatePassword(UpdatePasswordParams(newPassword: newPassword));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessageKey: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, step: PasswordResetStep.success)),
    );
  }

  void backToIdentifier() {
    emit(state.copyWith(step: PasswordResetStep.identifier, errorMessageKey: null));
  }

  void clearError() {
    if (state.errorMessageKey != null) {
      emit(state.copyWith(errorMessageKey: null));
    }
  }
}
