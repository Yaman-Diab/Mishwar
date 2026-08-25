import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/submit_review.dart';
import 'submit_review_state.dart';

@injectable
class SubmitReviewCubit extends Cubit<SubmitReviewState> {
  final SubmitReview _submitReview;

  SubmitReviewCubit(this._submitReview) : super(const SubmitReviewState());

  Future<void> submit({
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
    if (state.submitting) return;

    emit(
      state.copyWith(
        submitting: true,
        errorMessageKey: null,
        statusMessageKey: photoPaths.isNotEmpty
            ? 'submit_review_uploading_photos'
            : 'submit_review_publishing',
      ),
    );

    final result = await _submitReview(
      SubmitReviewParams(
        bookingId: bookingId,
        farmId: farmId,
        cleanliness: cleanliness,
        photoAccuracy: photoAccuracy,
        privacy: privacy,
        poolQuality: poolQuality,
        ownerConduct: ownerConduct,
        comment: comment,
        photoPaths: photoPaths,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(submitting: false, errorMessageKey: failure.message)),
      (review) =>
          emit(state.copyWith(submitting: false, step: SubmitReviewStep.success, result: review)),
    );
  }
}
