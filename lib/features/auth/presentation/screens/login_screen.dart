import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/glass_container.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                colorScheme.primary.withValues(alpha: 0.15),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ─────────────────────────
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: colorScheme.onPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxxl),

                    // ── Glass Form Card ────────────────────
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      opacity: 0.08,
                      blur: 25,
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 0.8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back', style: AppTextStyles.h2),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Sign in to continue to ${AppStrings.appName}',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: AppSizes.xxl),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Email',
                                  hint: 'you@example.com',
                                  controller: _emailController,
                                  validator: AppValidators.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(Icons.email_outlined, 
                                      color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                                ),
                                const SizedBox(height: AppSizes.lg),
                                CustomTextField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  validator: AppValidators.validatePassword,
                                  isPassword: true,
                                  prefixIcon: Icon(Icons.lock_outline_rounded, 
                                      color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                                  onFieldSubmitted: (_) => _onLogin(),
                                ),
                              ],
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(AppStrings.forgotPassword, style: AppTextStyles.link),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return AppButton(
                                label: AppStrings.login,
                                onPressed: _onLogin,
                                isLoading: state is AuthLoading,
                              );
                            },
                          ),
                          
                          const SizedBox(height: AppSizes.xl),
                          
                          Row(
                            children: [
                              Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR', style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4))),
                              ),
                              Expanded(child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.1))),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.xl),

                          AppButton(
                            label: 'Google',
                            onPressed: _onGoogleSignIn,
                            variant: AppButtonVariant.glass,
                            icon: const Icon(Icons.login_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.xxxl),

                    // ── Register Link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.dontHaveAccount,
                            style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.signup),
                          child: Text(
                            AppStrings.signUp,
                            style: AppTextStyles.labelLarge.copyWith(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
