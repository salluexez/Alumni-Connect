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
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignUpRequested(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: _selectedRole,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppStrings.signUp, style: AppTextStyles.h3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.lg),

                Text('Create your account', style: AppTextStyles.h2),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Join the Alumni Connect community',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Role Selector ─────────────────────────
                Text(AppStrings.selectRole, style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    _RoleChip(
                      label: AppStrings.student,
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == UserRole.student,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.student),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    _RoleChip(
                      label: AppStrings.alumni,
                      icon: Icons.school_outlined,
                      isSelected: _selectedRole == UserRole.alumni,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.alumni),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Form ──────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: AppStrings.fullName,
                        hint: 'Mohammed Ali',
                        controller: _nameController,
                        validator: AppValidators.validateName,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.textHint,
                          size: AppSizes.iconMd,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
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
                      ),
                      const SizedBox(height: AppSizes.lg),
                      CustomTextField(
                        label: AppStrings.password,
                        hint: 'Min 6 characters',
                        controller: _passwordController,
                        validator: AppValidators.validatePassword,
                        isPassword: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textHint,
                          size: AppSizes.iconMd,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      CustomTextField(
                        label: AppStrings.confirmPassword,
                        hint: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        validator: (val) => AppValidators.validateConfirmPassword(
                          val,
                          _passwordController.text,
                        ),
                        isPassword: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textHint,
                          size: AppSizes.iconMd,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSignUp(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Sign Up Button ────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Create Account',
                      onPressed: _onSignUp,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),

                const SizedBox(height: AppSizes.xl),

                // ── Login Link ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        AppStrings.login,
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

// ── Role Chip Widget ──────────────────────────────────────
class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingMd,
            horizontal: AppSizes.paddingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSizes.iconMd,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
