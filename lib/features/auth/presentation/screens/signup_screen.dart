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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
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
              center: Alignment.bottomRight,
              radius: 1.5,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                theme.scaffoldBackgroundColor,
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
                    icon: Icon(Icons.arrow_back_ios_new_rounded, 
                        color: colorScheme.onSurface, size: 20),
                    onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.login),
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6)),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Role Selector ─────────────────────────
                        Text(AppStrings.selectRole, 
                            style: AppTextStyles.labelMedium.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7))),
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
                                prefixIcon: Icon(Icons.person_outline, 
                                    color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextField(
                                label: AppStrings.email,
                                hint: 'you@example.com',
                                controller: _emailController,
                                validator: AppValidators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(Icons.email_outlined, 
                                    color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextField(
                                label: AppStrings.password,
                                hint: 'Min 6 characters',
                                controller: _passwordController,
                                validator: AppValidators.validatePassword,
                                isPassword: true,
                                prefixIcon: Icon(Icons.lock_outline, 
                                    color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.canPop() ? context.pop() : context.go(RouteNames.login),
                        child: Text(
                          AppStrings.login,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
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
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
