import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/usecases/mark_onboarding_seen.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final MarkOnboardingSeen _markOnboardingSeen;

  OnboardingCubit(this._markOnboardingSeen) : super(const OnboardingInProgress());

  /// يُنهي التعريف (تخطٍّ أو وصول للصفحة الأخيرة). يحاول حفظ العلامة
  /// محلياً، لكن **لا يعطّل الانتقال** إذا فشل الحفظ — أسوأ سيناريو هو
  /// ظهور التعريف مجدداً بالمرة القادمة، لا حبس المستخدم على الشاشة.
  Future<void> complete({required bool skipped}) async {
    await _markOnboardingSeen(const NoParams());
    emit(OnboardingCompleted(skipped: skipped));
  }
}
