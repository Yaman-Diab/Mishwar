import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../../../core/di/injection.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// شاشة تسجيل الدخول/إنشاء حساب الموحّدة — منقولة عن تصميم Claude Design
/// (مشروع «UI تحسين تسجيل الدخول»، نموذج 1b «الترويسة المختومة»).
///
/// ⚠️ إصلاح خلل تصميمي: التصميم الأصلي يرفع شريط التبويب فوق حدود
/// الترويسة عبر `margin-top` سالب محسوب على ارتفاع نص العنوان/الوصف —
/// وبما أن هذا الارتفاع يتغيّر فعلياً (نص الدخول يختلف طولاً عن نص
/// التسجيل)، ينتهي الشريط شبه ملاصق للنص فيتراكب معه أحياناً. هنا بدل
/// حساب هامش سالب مبني على نص متغيّر الطول، الترويسة تحجز مسافة أمان
/// **ثابتة** (`_headerReservedGap`) لا علاقة لها بطول النص إطلاقاً، وشريط
/// التبويب يُزاح بصرياً لأعلى (Transform.translate) بمقدار أقل من تلك
/// المسافة المحجوزة — فيبقى تراكبه محصوراً دائماً داخل منطقة خضراء فارغة
/// مضمونة، مهما اختلف طول العنوان أو الوصف بين وضعي الدخول والتسجيل.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView();

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> {
  static const _headerReservedGap = 36.0;
  static const _pillOverlap = 20.0;
  static const _switchDuration = Duration(milliseconds: 340);
  static const _switchCurve = Cubic(0.2, 0.8, 0.2, 1.0);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _wasSignupSubmission = false;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setMode(bool isLogin) {
    if (_isLogin == isLogin) return;
    setState(() {
      _isLogin = isLogin;
      _formKey.currentState?.reset();
    });
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    _wasSignupSubmission = !_isLogin;
    final cubit = context.read<AuthCubit>();
    if (_isLogin) {
      cubit.signIn(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      cubit.signUp(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
    }
  }

  void _onSso(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('auth_sso_not_configured'.tr(namedArgs: {'provider': provider})),
        backgroundColor: context.colors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (_wasSignupSubmission ? 'auth_success_signup' : 'auth_success_login').tr(),
              ),
              backgroundColor: colors.primary,
            ),
          );
          // TODO: بعد بناء شاشة رئيسية للمستخدم المسجَّل، وجّه إليها هنا
          // بدل ترك المستخدم على شاشة تسجيل الدخول نفسها.
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _buildHeader(colors),
            Expanded(child: _buildCard(context, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppSemanticColors colors) {
    return Container(
      width: double.infinity,
      color: colors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(26.w, 20.h, 26.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 34.r,
                    height: 34.r,
                    child: CustomPaint(
                      painter: SealMarkPainter(
                        ringColor: colors.background,
                        markColor: colors.background,
                        veinColor: colors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'app_name'.tr(),
                    style: TextStyle(
                      color: colors.background,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.h),
              AnimatedSwitcher(
                duration: _switchDuration,
                switchInCurve: _switchCurve,
                child: Text(
                  (_isLogin ? 'auth_welcome_back_title' : 'auth_get_started_title').tr(),
                  key: ValueKey(_isLogin),
                  style: TextStyle(
                    color: colors.background,
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250.w),
                child: AnimatedSwitcher(
                  duration: _switchDuration,
                  switchInCurve: _switchCurve,
                  child: Text(
                    (_isLogin ? 'auth_welcome_back_subtitle' : 'auth_get_started_subtitle').tr(),
                    key: ValueKey(_isLogin),
                    style: TextStyle(
                      color: colors.background.withValues(alpha: 0.66),
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
              // منطقة أمان محجوزة — فارغة دائماً بغض النظر عن طول النص
              // أعلاه، ليأمن شريط التبويب تراكبه معها لا مع النص.
              SizedBox(height: _headerReservedGap.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppSemanticColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0, -_pillOverlap.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: _buildTabPill(colors),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: _switchDuration,
                      switchInCurve: _switchCurve,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _isLogin
                          ? _buildLoginFields(colors)
                          : _buildSignupFields(colors),
                    ),
                    SizedBox(height: 22.h),
                    _buildSubmitButton(context, colors),
                    if (!_isLogin) ...[
                      SizedBox(height: 12.h),
                      _buildPrivacyTrustLine(colors),
                    ],
                    SizedBox(height: 20.h),
                    _buildDivider(colors),
                    SizedBox(height: 11.h),
                    _buildSsoButtons(context, colors),
                    SizedBox(height: 20.h),
                    _buildSwapPrompt(colors),
                    if (!_isLogin) ...[
                      SizedBox(height: 12.h),
                      _buildOwnerHint(colors),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(AppSemanticColors colors) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: _switchDuration,
            curve: _switchCurve,
            alignment: _isLogin ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: 'auth_cta_login'.tr(),
                  active: _isLogin,
                  colors: colors,
                  onTap: () => _setMode(true),
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: 'auth_cta_signup'.tr(),
                  active: !_isLogin,
                  colors: colors,
                  onTap: () => _setMode(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool active,
    required AppSemanticColors colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: active ? colors.primary : colors.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields(AppSemanticColors colors) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 22.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_identifier_label'.tr(),
          child: TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.identifier,
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_identifier_hint'.tr(),
              icon: Icons.alternate_email,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_password_label'.tr(),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.password,
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_password_hint'.tr(),
              icon: Icons.lock_outline,
              suffix: _buildPasswordToggle(colors),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => context.push('/password-reset'),
            child: Text(
              'auth_forgot_password'.tr(),
              style: TextStyle(
                color: colors.primary,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupFields(AppSemanticColors colors) {
    final strength = _passwordStrength(_passwordController.text);
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 22.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_full_name_label'.tr(),
          child: TextFormField(
            controller: _nameController,
            validator: Validators.fullName,
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_full_name_hint'.tr(),
              icon: Icons.person_outline,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_identifier_label'.tr(),
          child: TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.identifier,
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_identifier_hint'.tr(),
              icon: Icons.alternate_email,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_password_label'.tr(),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: Validators.password,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_password_hint_signup'.tr(),
              icon: Icons.lock_outline,
              suffix: _buildPasswordToggle(colors),
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
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildLabeledField(
          colors: colors,
          label: 'auth_confirm_password_label'.tr(),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            validator: (v) => Validators.confirmPassword(v, _passwordController.text),
            decoration: _inputDecoration(
              colors: colors,
              hint: 'auth_confirm_password_hint'.tr(),
              icon: Icons.lock_outline,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11.5.sp,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: '${'auth_terms_prefix'.tr()} '),
              TextSpan(
                text: 'auth_terms_link'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${'auth_terms_and'.tr()} '),
              TextSpan(
                text: 'auth_privacy_link'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required AppSemanticColors colors,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required AppSemanticColors colors,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, size: 18.sp, color: colors.textSecondary),
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

  Widget _buildPasswordToggle(AppSemanticColors colors) {
    return IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 19.sp,
        color: colors.textSecondary,
      ),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppSemanticColors colors) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          height: 54.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    (_isLogin ? 'auth_cta_login' : 'auth_cta_signup').tr(),
                    style: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyTrustLine(AppSemanticColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 13.sp, color: colors.textSecondary),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            'auth_privacy_trust_line'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 11.5.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(AppSemanticColors colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'auth_or_divider'.tr(),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.border, height: 1)),
      ],
    );
  }

  Widget _buildSsoButtons(BuildContext context, AppSemanticColors colors) {
    return Column(
      children: [
        _buildSsoButton(
          context: context,
          colors: colors,
          label: 'auth_sso_google'.tr(),
          provider: 'Google',
          icon: Icons.g_mobiledata,
        ),
        SizedBox(height: 11.h),
        _buildSsoButton(
          context: context,
          colors: colors,
          label: 'auth_sso_apple'.tr(),
          provider: 'Apple',
          icon: Icons.apple,
        ),
      ],
    );
  }

  Widget _buildSsoButton({
    required BuildContext context,
    required AppSemanticColors colors,
    required String label,
    required String provider,
    required IconData icon,
  }) {
    return SizedBox(
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () => _onSso(context, provider),
        icon: Icon(icon, size: 20.sp, color: colors.textPrimary),
        label: Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.primary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapPrompt(AppSemanticColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          (_isLogin ? 'auth_swap_prompt_to_signup' : 'auth_swap_prompt_to_login').tr(),
          style: TextStyle(color: colors.textSecondary, fontSize: 13.sp),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _setMode(!_isLogin),
          child: Text(
            (_isLogin ? 'auth_swap_action_to_signup' : 'auth_swap_action_to_login').tr(),
            style: TextStyle(
              color: colors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerHint(AppSemanticColors colors) {
    return Center(
      child: Text(
        'auth_owner_signup_hint'.tr(),
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _PasswordStrength _passwordStrength(String pw) {
    if (pw.isEmpty) {
      return _PasswordStrength(0, const Color(0x00000000), 'auth_password_strength_weak');
    }
    var s = 0;
    if (pw.length >= 6) s++;
    if (pw.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw) || RegExp(r'[^\w\s]').hasMatch(pw)) s++;
    if (RegExp(r'\d').hasMatch(pw)) s++;

    if (s <= 1) {
      return _PasswordStrength(0.3, Colors.red.shade700, 'auth_password_strength_weak');
    }
    if (s == 2) {
      return _PasswordStrength(0.55, Colors.orange.shade700, 'auth_password_strength_medium');
    }
    if (s == 3) {
      return _PasswordStrength(0.78, Colors.green.shade700, 'auth_password_strength_good');
    }
    return _PasswordStrength(1.0, Colors.green.shade700, 'auth_password_strength_strong');
  }
}

class _PasswordStrength {
  final double factor;
  final Color color;
  final String labelKey;

  const _PasswordStrength(this.factor, this.color, this.labelKey);
}
