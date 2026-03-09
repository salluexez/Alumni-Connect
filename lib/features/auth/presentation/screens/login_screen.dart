import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../navigation/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isAdmin) {
            context.go(RouteNames.adminDashboard);
          } else {
            context.go(RouteNames.dashboard);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xxxl),

                // ── Logo & Header ─────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(AppStrings.appName, style: AppTextStyles.h1),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        AppStrings.appTagline,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxxl),

                // ── Form ──────────────────────────────────
                Text('Welcome back', style: AppTextStyles.h2),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sign in to your account',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xxl),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: AppStrings.email,
                        hint: 'you@example.com',
                        controller: _emailController,
                        validator: AppValidators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textHint,
                          size: AppSizes.iconMd,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      CustomTextField(
                        label: AppStrings.password,
                        hint: 'Enter your password',
                        controller: _passwordController,
                        validator: AppValidators.validatePassword,
                        isPassword: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textHint,
                          size: AppSizes.iconMd,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLogin(),
                      ),
                    ],
                  ),
                ),

                // ── Forgot Password ───────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(AppStrings.forgotPassword,
                        style: AppTextStyles.link),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Login Button ──────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: AppStrings.login,
                      onPressed: _onLogin,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Divider ───────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMd),
                      child: Text('OR',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textHint)),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Google Sign In ────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: AppStrings.continueWithGoogle,
                      onPressed: _onGoogleSignIn,
                      variant: AppButtonVariant.secondary,
                      isLoading: state is AuthLoading,
                      icon: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Sign Up Link ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.signup),
                      child: Text(
                        AppStrings.signUp,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
