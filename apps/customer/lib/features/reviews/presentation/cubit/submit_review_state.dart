import 'package:equatable/equatable.dart';

import '../../domain/entities/review_entity.dart';

enum SubmitReviewStep { form, success }

class SubmitReviewState extends Equatable {
  final SubmitReviewStep step;
  final bool submitting;
  final String? statusMessageKey;
  final String? errorMessageKey;
  final ReviewEntity? result;

  const SubmitReviewState({
    this.step = SubmitReviewStep.form,
    this.submitting = false,
    this.statusMessageKey,
    this.errorMessageKey,
    this.result,
  });

  SubmitReviewState copyWith({
    SubmitReviewStep? step,
    bool? submitting,
    String? statusMessageKey,
    String? errorMessageKey,
    ReviewEntity? result,
  }) {
    return SubmitReviewState(
      step: step ?? this.step,
      submitting: submitting ?? this.submitting,
      statusMessageKey: statusMessageKey,
      errorMessageKey: errorMessageKey,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [step, submitting, statusMessageKey, errorMessageKey, result];
}
