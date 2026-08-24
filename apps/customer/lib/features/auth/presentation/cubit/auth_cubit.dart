import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mashwar_core/mashwar_core.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignUp _signUp;
  final SignIn _signIn;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthCubit(this._signUp, this._signIn, this._signOut, this._getCurrentUser)
    : super(const AuthInitial());

  Future<void> checkCurrentUser() async {
    emit(const AuthLoading());
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      ),
    );
  }

  Future<void> signUp({
    required String identifier,
    required String password,
    required String fullName,
  }) async {
    emit(const AuthLoading());
    final result = await _signUp(
      SignUpParams(identifier: identifier, password: password, fullName: fullName),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signIn({required String identifier, required String password}) async {
    emit(const AuthLoading());
    final result = await _signIn(
      SignInParams(identifier: identifier, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    final result = await _signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
