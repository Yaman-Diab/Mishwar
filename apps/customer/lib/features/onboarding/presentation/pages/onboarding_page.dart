import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_illustrations.dart';

class _OnboardingPageData {
  final CustomPainter Function(AppSemanticColors colors) painterBuilder;
  final String titleKey;
  final String subtitleKey;

  const _OnboardingPageData({
    required this.painterBuilder,
    required this.titleKey,
    required this.subtitleKey,
  });
}

const _pages = [
  _OnboardingPageData(
    painterBuilder: _sealPainter,
    titleKey: 'onboarding_page1_title',
    subtitleKey: 'onboarding_page1_subtitle',
  ),
  _OnboardingPageData(
    painterBuilder: _calendarPainter,
    titleKey: 'onboarding_page2_title',
    subtitleKey: 'onboarding_page2_subtitle',
  ),
  _OnboardingPageData(
    painterBuilder: _reviewPainter,
    titleKey: 'onboarding_page3_title',
    subtitleKey: 'onboarding_page3_subtitle',
  ),
];

CustomPainter _sealPainter(AppSemanticColors c) =>
    SealCheckPainter(ringColor: c.primary, checkColor: c.accent);
CustomPainter _calendarPainter(AppSemanticColors c) =>
    CalendarLockPainter(lineColor: c.primary, accentColor: c.accent);
CustomPainter _reviewPainter(AppSemanticColors c) =>
    ReviewSparklePainter(lineColor: c.primary, accentColor: c.accent);

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onCtaPressed(BuildContext context) {
    if (_isLastPage) {
      context.read<OnboardingCubit>().complete(skipped: false);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 6.h),
                  child: TextButton(
                    onPressed: () =>
                        context.read<OnboardingCubit>().complete(skipped: true),
                    child: Text(
                      'onboarding_skip'.tr(),
                      style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, _) {
                        final page = _pageController.hasClients &&
                                _pageController.page != null
                            ? _pageController.page!
                            : _currentPage.toDouble();
                        final distance = (page - index).clamp(-1.0, 1.0);
                        final opacity = (1 - distance.abs() * 1.3).clamp(0.0, 1.0);
                        final translateY = distance.abs() * 16;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 210.h,
                                child: Center(
                                  child: SizedBox(
                                    width: 168.r,
                                    height: 168.r,
                                    child: CustomPaint(
                                      painter: _pages[index].painterBuilder(colors),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Opacity(
                                opacity: opacity,
                                child: Transform.translate(
                                  offset: Offset(0, translateY.h),
                                  child: Text(
                                    _pages[index].titleKey.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.sp,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Opacity(
                                opacity: opacity,
                                child: Transform.translate(
                                  offset: Offset(0, translateY.h),
                                  child: Text(
                                    _pages[index].subtitleKey.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15.5.sp,
                                      height: 1.7,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) {
                    final page = _pageController.hasClients &&
                            _pageController.page != null
                        ? _pageController.page!
                        : _currentPage.toDouble();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => OnboardingDotIndicator(
                          distanceFromCurrentPage: page - i,
                          colors: colors,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: GestureDetector(
                  onTap: () => _onCtaPressed(context),
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    child: Text(
                      _isLastPage
                          ? 'onboarding_start_now'.tr()
                          : 'onboarding_next'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}
