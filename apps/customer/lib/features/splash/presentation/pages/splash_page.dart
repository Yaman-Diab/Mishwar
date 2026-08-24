import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

/// شاشة البداية — نسخة «2b: الختم يفتح الشاشة» من تصميم Claude Design
/// (مشروع «تحسين UI الختم الأخضر»، ملف Mishwar Splash.dc.html).
///
/// تسلسل واحد لا يتكرر (لا loop بالإنتاج، خلافاً لمعاينة التصميم):
/// الحلقة تُرسم (0–300ms) ← الختم يهبط بارتداد (300–700ms) ← الاسم
/// والشعار يظهران (700–1370ms) ← شريط فحص الجلسة يمتلئ (1100–2592ms) ←
/// قرص الختم نفسه يتمدد كريمياً ليبتلع الشاشة (2592–3312ms) ويسلّمها
/// للشاشة التالية. التوقيتات ودوال Cubic منقولة حرفياً عن الـkeyframes
/// الأصلية (نسب مئوية من 3600ms).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplashCubit>(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  static const _ringCurve = Cubic(0.32, 0.72, 0.2, 1.0);
  static const _markCurve = Cubic(0.28, 1.35, 0.5, 1.0);
  static const _wordCurve = Cubic(0.2, 0.7, 0.2, 1.0);
  static const _rippleCurve = Cubic(0.2, 0.6, 0.3, 1.0);
  static const _barCurve = Cubic(0.4, 0.6, 0.3, 1.0);
  static const _openCurve = Cubic(0.55, 0.0, 0.35, 1.0);

  late final AnimationController _controller;

  late final Animation<double> _ringProgress;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markDy;
  late final Animation<double> _markScale;
  late final Animation<double> _wordOpacity;
  late final Animation<double> _wordDy;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineDy;
  late final Animation<double> _ripple1Opacity;
  late final Animation<double> _ripple1Scale;
  late final Animation<double> _ripple2Opacity;
  late final Animation<double> _ripple2Scale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;
  late final Animation<double> _barProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<double> _swallowOpacity;
  late final Animation<double> _swallowScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _ringProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.083, curve: _ringCurve),
    );

    _markOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 8.3),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2.7),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 89.0),
    ]).animate(_controller);

    _markDy = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(-26.0), weight: 8.3),
      TweenSequenceItem(
        tween: Tween(begin: -26.0, end: 5.0).chain(CurveTween(curve: _markCurve)),
        weight: 6.7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 5.0, end: -2.0).chain(CurveTween(curve: _markCurve)),
        weight: 2.4,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -2.0, end: 0.0).chain(CurveTween(curve: _markCurve)),
        weight: 2.0,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 80.6),
    ]).animate(_controller);

    _markScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.92), weight: 8.3),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.035).chain(CurveTween(curve: _markCurve)),
        weight: 6.7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.035, end: 0.992).chain(CurveTween(curve: _markCurve)),
        weight: 2.4,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.992, end: 1.0).chain(CurveTween(curve: _markCurve)),
        weight: 2.0,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80.6),
    ]).animate(_controller);

    _wordOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 19.4),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: _wordCurve)),
        weight: 11.2,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 69.4),
    ]).animate(_controller);

    _wordDy = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(12.0), weight: 19.4),
      TweenSequenceItem(
        tween: Tween(begin: 12.0, end: 0.0).chain(CurveTween(curve: _wordCurve)),
        weight: 11.2,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 69.4),
    ]).animate(_controller);

    _taglineOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 26.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.62).chain(CurveTween(curve: _wordCurve)),
        weight: 12.0,
      ),
      TweenSequenceItem(tween: ConstantTween(0.62), weight: 62.0),
    ]).animate(_controller);

    _taglineDy = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(8.0), weight: 26.0),
      TweenSequenceItem(
        tween: Tween(begin: 8.0, end: 0.0).chain(CurveTween(curve: _wordCurve)),
        weight: 12.0,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 62.0),
    ]).animate(_controller);

    _ripple1Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 17.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.45).chain(CurveTween(curve: _rippleCurve)),
        weight: 2.4,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.45, end: 0.0).chain(CurveTween(curve: _rippleCurve)),
        weight: 16.6,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 64.0),
    ]).animate(_controller);

    _ripple1Scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.86), weight: 17.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.86, end: 1.55).chain(CurveTween(curve: _rippleCurve)),
        weight: 19.0,
      ),
      TweenSequenceItem(tween: ConstantTween(1.55), weight: 64.0),
    ]).animate(_controller);

    _ripple2Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 21.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.28).chain(CurveTween(curve: _rippleCurve)),
        weight: 3.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.28, end: 0.0).chain(CurveTween(curve: _rippleCurve)),
        weight: 20.0,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 56.0),
    ]).animate(_controller);

    _ripple2Scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.86), weight: 21.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.86, end: 1.9).chain(CurveTween(curve: _rippleCurve)),
        weight: 23.0,
      ),
      TweenSequenceItem(tween: ConstantTween(1.9), weight: 56.0),
    ]).animate(_controller);

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 17.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.34).chain(CurveTween(curve: Curves.easeOut)),
        weight: 2.4,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.34, end: 0.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10.6,
      ),
      TweenSequenceItem(tween: ConstantTween(0.2), weight: 70.0),
    ]).animate(_controller);

    _glowScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.6), weight: 17.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 13.0,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70.0),
    ]).animate(_controller);

    _barProgress = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30.6),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: _barCurve)),
        weight: 41.4,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 28.0),
    ]).animate(_controller);

    _contentOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70.0),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10.0,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20.0),
    ]).animate(_controller);

    _swallowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 72.0),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1.5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 26.5),
    ]).animate(_controller);

    _swallowScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 72.0),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 6.6).chain(CurveTween(curve: _openCurve)),
        weight: 20.0,
      ),
      TweenSequenceItem(tween: ConstantTween(6.6), weight: 8.0),
    ]).animate(_controller);

    // يعمل مرة واحدة فقط — بخلاف معاينة التصميم اللي بتلف كل 3.6 ثانية.
    // عند اكتمال الحركة نطلب من SplashCubit تحديد الوجهة (تعريف أول
    // مرة أم تسجيل دخول مباشرة)، وننتقل فعلياً عبر BlocListener بالأسفل.
    _controller.addStatusListener(_onAnimationStatusChanged);
    _controller.forward();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      context.read<SplashCubit>().resolveDestination();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        switch (state) {
          case SplashDestinationOnboarding():
            context.go('/onboarding');
          case SplashDestinationLogin():
            context.go('/login');
          case SplashLoading():
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.primary,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildBackgroundGlow(colors),
                Center(
                  child: Opacity(
                    opacity: _contentOpacity.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSeal(colors),
                        SizedBox(height: 34.h),
                        _buildWordmark(colors),
                      ],
                    ),
                  ),
                ),
                _buildSessionBar(colors),
                _buildSwallowOverlay(colors),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow(AppSemanticColors colors) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.24),
            radius: 1.2,
            colors: [
              colors.background.withValues(alpha: 0.08),
              colors.background.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.62],
          ),
        ),
      ),
    );
  }

  Widget _buildSeal(AppSemanticColors colors) {
    final size = 184.r;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الهالة الضوئية الدافئة خلف الختم عند الاستقرار.
          Opacity(
            opacity: _glowOpacity.value,
            child: Transform.scale(
              scale: _glowScale.value,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 16.r, sigmaY: 16.r),
                child: Container(
                  width: 158.r,
                  height: 158.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.background,
                  ),
                ),
              ),
            ),
          ),
          // الموجة الأولى — ارتداد الاستقرار.
          Opacity(
            opacity: _ripple1Opacity.value,
            child: Transform.scale(
              scale: _ripple1Scale.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 2),
                ),
              ),
            ),
          ),
          // الموجة الثانية — الارتداد المزدوج المميّز لهذا النموذج (2b).
          Opacity(
            opacity: _ripple2Opacity.value,
            child: Transform.scale(
              scale: _ripple2Scale.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 1.5),
                ),
              ),
            ),
          ),
          // الحلقة — تُرسم تدريجياً (سطح مستقل عن الختم، بلا ارتداد).
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: SealMarkPainter(
                showMark: false,
                ringProgress: _ringProgress.value,
                ringColor: colors.background,
                markColor: colors.background,
                veinColor: colors.primary,
              ),
            ),
          ),
          // الختم (صح/ورقة) — يهبط بارتداد فوق الحلقة.
          Opacity(
            opacity: _markOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _markDy.value.r),
              child: Transform.scale(
                scale: _markScale.value,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: SealMarkPainter(
                      showRing: false,
                      markColor: colors.background,
                      veinColor: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordmark(AppSemanticColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: _wordOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _wordDy.value.h),
            child: Text(
              'app_name'.tr(),
              style: TextStyle(
                color: colors.background,
                fontSize: 46.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Opacity(
          opacity: _taglineOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _taglineDy.value.h),
            child: Text(
              'splash_tagline'.tr(),
              style: TextStyle(
                color: colors.background,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionBar(AppSemanticColors colors) {
    return Positioned(
      bottom: 74.h,
      left: 0,
      right: 0,
      child: Center(
        child: Opacity(
          opacity: _contentOpacity.value,
          child: Container(
            width: 132.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: colors.background.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FractionallySizedBox(
                widthFactor: _barProgress.value,
                child: Container(color: colors.background),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// قرص الختم يتمدد كريمياً من مركز الرمز حتى يبتلع الشاشة كاملة —
  /// الانتقال نفسه يصبح جزءاً من العلامة بدل تلاشٍ عادي للفراغ.
  Widget _buildSwallowOverlay(AppSemanticColors colors) {
    return IgnorePointer(
      child: Opacity(
        opacity: _swallowOpacity.value,
        child: Center(
          child: Transform.scale(
            scale: _swallowScale.value,
            child: Container(
              width: 184.r,
              height: 184.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.background,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
