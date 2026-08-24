import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../onboarding/domain/usecases/has_seen_onboarding.dart';
import 'splash_state.dart';

/// اعتماد Splash على `domain/usecases` تبع ميزة Onboarding استثناء واعٍ
/// من قاعدة استقلال الميزات: قرار التوجيه بعد شاشة البداية (تعريف أول
/// مرة أم تسجيل دخول مباشرة) هو بالضبط سبب وجود Splash، فالاعتماد على
/// عقد Onboarding (واجهة لا تنفيذ) هنا أنسب من تكرار منطق تخزين محلي
/// مطابق داخل كل من الميزتين.
@injectable
class SplashCubit extends Cubit<SplashState> {
  final HasSeenOnboarding _hasSeenOnboarding;

  SplashCubit(this._hasSeenOnboarding) : super(const SplashLoading());

  Future<void> resolveDestination() async {
    final result = await _hasSeenOnboarding(const NoParams());
    result.fold(
      // فشل غير متوقع بقراءة العلامة المحلية: نعرض التعريف بدل ما
      // نخاطر بتخطّيه لمستخدم جديد فعلياً.
      (failure) => emit(const SplashDestinationOnboarding()),
      (seen) => emit(
        seen ? const SplashDestinationLogin() : const SplashDestinationOnboarding(),
      ),
    );
  }
}
