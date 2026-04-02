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
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomRight,
              radius: 1.5,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account', style: AppTextStyles.h1),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Join the Alumni Connect community today',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  GlassContainer(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    opacity: 0.08,
                    blur: 30,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Role Selector ─────────────────────────
                        Text(AppStrings.selectRole, style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: [
                            _RoleChip(
                              label: AppStrings.student,
                              isSelected: _selectedRole == UserRole.student,
                              onTap: () => setState(() => _selectedRole = UserRole.student),
                            ),
                            const SizedBox(width: AppSizes.md),
                            _RoleChip(
                              label: AppStrings.alumni,
                              isSelected: _selectedRole == UserRole.alumni,
                              onTap: () => setState(() => _selectedRole = UserRole.alumni),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                label: AppStrings.fullName,
                                hint: 'Mohammed Ali',
                                controller: _nameController,
                                validator: AppValidators.validateName,
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white54, size: 20),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextField(
                                label: AppStrings.email,
                                hint: 'you@example.com',
                                controller: _emailController,
                                validator: AppValidators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextField(
                                label: AppStrings.password,
                                hint: 'Min 6 characters',
                                controller: _passwordController,
                                validator: AppValidators.validatePassword,
                                isPassword: true,
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton(
                              label: 'Create Account',
                              onPressed: _onSignUp,
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.alreadyHaveAccount,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          AppStrings.login,
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
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
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

