import 'package:equatable/equatable.dart';

enum PasswordResetStep { identifier, code, password, success }

class PasswordResetState extends Equatable {
  final PasswordResetStep step;
  final bool isLoading;
  final String? errorMessageKey;
  final String identifier;

  const PasswordResetState({
    this.step = PasswordResetStep.identifier,
    this.isLoading = false,
    this.errorMessageKey,
    this.identifier = '',
  });

  PasswordResetState copyWith({
    PasswordResetStep? step,
    bool? isLoading,
    String? errorMessageKey,
    String? identifier,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessageKey: errorMessageKey,
      identifier: identifier ?? this.identifier,
    );
  }

  @override
  List<Object?> get props => [step, isLoading, errorMessageKey, identifier];
}
