import 'package:equatable/equatable.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress();
}

/// [skipped] يميّز سبب الإنهاء فقط لأغراض تحليلية مستقبلية محتملة —
/// كلا المسارين (تخطي أو إنهاء طبيعي) يؤديان لنفس الوجهة (تسجيل الدخول).
class OnboardingCompleted extends OnboardingState {
  final bool skipped;

  const OnboardingCompleted({required this.skipped});

  @override
  List<Object?> get props => [skipped];
}
