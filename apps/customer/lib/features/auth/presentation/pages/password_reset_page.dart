import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';

const _resendCooldown = 45;

/// شاشة استعادة كلمة المرور — منقولة عن تصميم Claude Design (مشروع
/// «UI تحسين تسجيل الدخول»، ملف Mishwar Password Reset.dc.html).
/// أربع خطوات بشاشة واحدة: هوية ← رمز تحقق ← كلمة مرور جديدة ← نجاح.
class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PasswordResetCubit>(),
      child: const _PasswordResetView(),
    );
  }
}

class _PasswordResetView extends StatefulWidget {
  const _PasswordResetView();

  @override
  State<_PasswordResetView> createState() => _PasswordResetViewState();
}

class _PasswordResetViewState extends State<_PasswordResetView>
    with SingleTickerProviderStateMixin {
  static const _switchDuration = Duration(milliseconds: 300);
  static const _switchCurve = Cubic(0.2, 0.8, 0.2, 1.0);
  static const _markCurve = Cubic(0.28, 1.35, 0.5, 1.0);
  static const _ringCurve = Cubic(0.32, 0.72, 0.2, 1.0);

  final _identifierFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  String? _codeError;
  Timer? _countdownTimer;
  int _secondsLeft = _resendCooldown;

  late final AnimationController _successController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _successOpacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
  ]).animate(_successController);
  late final Animation<double> _successScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.7, end: 1.08).chain(CurveTween(curve: _markCurve)),
      weight: 60,
    ),
    TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 40),
  ]).animate(_successController);
  late final Animation<double> _successRingProgress = CurvedAnimation(
    parent: _successController,
    curve: const Interval(0.08, 1.0, curve: _ringCurve),
  );

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _successController.dispose();
    _identifierController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _countdownLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _maskIdentifier(String value) {
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      final parts = trimmed.split('@');
      final name = parts.first;
      final domain = parts.length > 1 ? parts[1] : '';
      final headLen = name.length >= 2 ? 2 : name.length;
      final head = name.substring(0, headLen);
      final dots = '•' * (name.length - headLen).clamp(1, 99);
      return '$head$dots@$domain';
    }
    if (trimmed.length >= 6) {
      return '${trimmed.substring(0, 4)}••••${trimmed.substring(trimmed.length - 2)}';
    }
    return trimmed;
  }

  void _submitIdentifier(BuildContext context) {
    if (!_identifierFormKey.currentState!.validate()) return;
    context.read<PasswordResetCubit>().sendCode(_identifierController.text.trim());
  }

  void _submitCode(BuildContext context) {
    if (_codeController.text.length != 6) {
      setState(() => _codeError = 'password_reset_code_incomplete'.tr());
      return;
    }
    setState(() => _codeError = null);
    context.read<PasswordResetCubit>().verifyCode(_codeController.text);
  }

  void _submitPassword(BuildContext context) {
    if (!_passwordFormKey.currentState!.validate()) return;
    context.read<PasswordResetCubit>().updatePassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        if (state.step == PasswordResetStep.code) {
          _startCountdown();
          Future.delayed(
            const Duration(milliseconds: 60),
            () => _codeFocusNode.requestFocus(),
          );
        } else {
          _countdownTimer?.cancel();
        }
        if (state.step == PasswordResetStep.success) {
          _successController.forward(from: 0);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: BlocBuilder<PasswordResetCubit, PasswordResetState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildBackRow(context, colors, state),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(26.w, 14.h, 26.w, 30.h),
                      child: AnimatedSwitcher(
                        duration: _switchDuration,
                        switchInCurve: _switchCurve,
                        child: switch (state.step) {
                          PasswordResetStep.identifier =>
                            _buildIdentifierStep(context, colors, state),
                          PasswordResetStep.code => _buildCodeStep(context, colors, state),
                          PasswordResetStep.password =>
                            _buildPasswordStep(context, colors, state),
                          PasswordResetStep.success => _buildSuccessStep(context, colors),
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackRow(
    BuildContext context,
    AppSemanticColors colors,
    PasswordResetState state,
  ) {
    final show = state.step == PasswordResetStep.code;
    return SizedBox(
      height: 34.h,
      child: show
          ? Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => context.read<PasswordResetCubit>().backToIdentifier(),
                icon: Icon(Icons.arrow_back_ios_new, size: 14.sp, color: colors.primary),
                label: Text(
                  'password_reset_back_label'.tr(),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIdentifierStep(
    BuildContext context,
    AppSemanticColors colors,
    PasswordResetState state,
  ) {
    return Form(
      key: _identifierFormKey,
      child: Column(
        key: const ValueKey('identifier'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 18.h),
          Text(
            'password_reset_identifier_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            'password_reset_identifier_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5.sp, color: colors.textSecondary, height: 1.7),
          ),
          SizedBox(height: 28.h),
          Text(
            'auth_identifier_label'.tr(),
            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
          SizedBox(height: 7.h),
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.identifier,
            decoration: _inputDecoration(colors, hint: 'auth_identifier_hint'.tr()),
          ),
          if (state.errorMessageKey != null) ...[
            SizedBox(height: 6.h),
            Text(
              state.errorMessageKey!.tr(),
              style: TextStyle(color: colors.error, fontSize: 11.5.sp, fontWeight: FontWeight.w600),
            ),
          ],
          SizedBox(height: 40.h),
          _buildPrimaryButton(
            label: 'password_reset_send_code'.tr(),
            isLoading: state.isLoading,
            onPressed: () => _submitIdentifier(context),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep(
    BuildContext context,
    AppSemanticColors colors,
    PasswordResetState state,
  ) {
    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 18.h),
        Text(
          'password_reset_code_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: colors.textPrimary),
        ),
        SizedBox(height: 6.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 13.5.sp, color: colors.textSecondary, height: 1.75),
            children: [
              TextSpan(text: '${'password_reset_code_sent_to'.tr()} '),
              TextSpan(
                text: _maskIdentifier(state.identifier),
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        _buildCodeBoxes(colors),
        if ((state.errorMessageKey ?? _codeError) != null) ...[
          SizedBox(height: 10.h),
          Text(
            (state.errorMessageKey?.tr()) ?? _codeError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.error, fontSize: 11.5.sp, fontWeight: FontWeight.w600),
          ),
        ],
        SizedBox(height: 18.h),
        Center(
          child: _secondsLeft > 0
              ? Text(
                  'password_reset_resend_countdown'.tr(namedArgs: {'time': _countdownLabel}),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13.sp),
                )
              : TextButton(
                  onPressed: () => context.read<PasswordResetCubit>().resendCode(),
                  child: Text(
                    'password_reset_resend'.tr(),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        SizedBox(height: 40.h),
        _buildPrimaryButton(
          label: 'password_reset_verify'.tr(),
          isLoading: state.isLoading,
          onPressed: () => _submitCode(context),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildCodeBoxes(AppSemanticColors colors) {
    return GestureDetector(
      onTap: () => _codeFocusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _codeController,
            builder: (context, _) {
              final code = _codeController.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final char = i < code.length ? code[i] : '';
                  final isCursor = i == code.length;
                  final borderColor =
                      (char.isNotEmpty || isCursor) ? colors.primary : colors.border;
                  return Container(
                    width: 46.w,
                    height: 56.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.5.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor, width: 1.6),
                    ),
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 300.w,
              height: 56.h,
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep(
    BuildContext context,
    AppSemanticColors colors,
    PasswordResetState state,
  ) {
    final strength = _passwordStrength(_passwordController.text);
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey('password'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 18.h),
          Text(
            'password_reset_new_password_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            'password_reset_new_password_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5.sp, color: colors.textSecondary, height: 1.7),
          ),
          SizedBox(height: 26.h),
          Text(
            'password_reset_new_password_label'.tr(),
            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
          SizedBox(height: 7.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.password,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              colors,
              hint: 'auth_password_hint_signup'.tr(),
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 19.sp,
                  color: colors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: LinearProgressIndicator(
                    value: strength.factor,
                    minHeight: 4.h,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation(strength.color),
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Text(
                strength.labelKey.tr(),
                style: TextStyle(color: colors.textSecondary, fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'auth_confirm_password_label'.tr(),
            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
          SizedBox(height: 7.h),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            validator: (v) => Validators.confirmPassword(v, _passwordController.text),
            decoration: _inputDecoration(colors, hint: 'auth_confirm_password_hint'.tr()),
          ),
          if (state.errorMessageKey != null) ...[
            SizedBox(height: 6.h),
            Text(
              state.errorMessageKey!.tr(),
              style: TextStyle(color: colors.error, fontSize: 11.5.sp, fontWeight: FontWeight.w600),
            ),
          ],
          SizedBox(height: 30.h),
          _buildPrimaryButton(
            label: 'password_reset_update_button'.tr(),
            isLoading: state.isLoading,
            onPressed: () => _submitPassword(context),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context, AppSemanticColors colors) {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _successController,
          builder: (context, _) {
            return Opacity(
              opacity: _successOpacity.value,
              child: Transform.scale(
                scale: _successScale.value,
                child: SizedBox(
                  width: 64.r,
                  height: 64.r,
                  child: CustomPaint(
                    painter: SealMarkPainter(
                      ringProgress: _successRingProgress.value,
                      ringColor: colors.primary,
                      markColor: colors.primary,
                      veinColor: colors.background,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 22.h),
        Text(
          'password_reset_success_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800, color: colors.textPrimary),
        ),
        SizedBox(height: 6.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250.w),
          child: Text(
            'password_reset_success_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5.sp, color: colors.textSecondary, height: 1.7),
          ),
        ),
        SizedBox(height: 30.h),
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            label: 'password_reset_back_to_login'.tr(),
            isLoading: false,
            onPressed: () => context.go('/login'),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
    required AppSemanticColors colors,
  }) {
    return SizedBox(
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(AppSemanticColors colors, {required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }

  _PwStrength _passwordStrength(String pw) {
    if (pw.isEmpty) {
      return _PwStrength(0, const Color(0x00000000), 'auth_password_strength_weak');
    }
    var s = 0;
    if (pw.length >= 6) s++;
    if (pw.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw) || RegExp(r'[^\w\s]').hasMatch(pw)) s++;
    if (RegExp(r'\d').hasMatch(pw)) s++;

    if (s <= 1) return _PwStrength(0.3, Colors.red.shade700, 'auth_password_strength_weak');
    if (s == 2) return _PwStrength(0.55, Colors.orange.shade700, 'auth_password_strength_medium');
    if (s == 3) return _PwStrength(0.78, Colors.green.shade700, 'auth_password_strength_good');
    return _PwStrength(1.0, Colors.green.shade700, 'auth_password_strength_strong');
  }
}

class _PwStrength {
  final double factor;
  final Color color;
  final String labelKey;

  const _PwStrength(this.factor, this.color, this.labelKey);
}
