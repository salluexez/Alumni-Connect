import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../navigation/route_names.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/alumni_cubit.dart';
import '../cubit/alumni_state.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _batchYearController;
  bool _isAvailableForMentoring = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
    _skillsController = TextEditingController(
      text: widget.user.skills.join(', '),
    );
    _companyController = TextEditingController(text: widget.user.company);
    _positionController = TextEditingController(text: widget.user.position);
    _batchYearController = TextEditingController(
      text: widget.user.batchYear?.toString(),
    );
    _isAvailableForMentoring = widget.user.isAvailableForMentoring;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _batchYearController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'skills': skillsList,
      'isAvailableForMentoring': _isAvailableForMentoring,
    };

    if (_companyController.text.isNotEmpty) {
      updates['company'] = _companyController.text.trim();
    }
    if (_positionController.text.isNotEmpty) {
      updates['position'] = _positionController.text.trim();
    }
    if (_batchYearController.text.isNotEmpty) {
      updates['batchYear'] = int.tryParse(_batchYearController.text.trim());
    }

    context.read<ProfileCubit>().updateProfile(widget.user, updates);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: context.appColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.profile);
          }
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Edit Profile', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
          actions: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileUpdating) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }
                return IconButton(
                    icon: Icon(
                      Icons.check_rounded,
                      color: colorScheme.primary,
                    ),
                  onPressed: _onSave,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Info', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Bio',
                  hint: 'Tell us a bit about yourself...',
                  controller: _bioController,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSizes.xxl),

                Text('Professional Details', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Company',
                        hint: 'e.g. Google',
                        controller: _companyController,
                        prefixIcon: Icon(Icons.business_outlined, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: CustomTextField(
                        label: 'Position',
                        hint: 'e.g. Engineer',
                        controller: _positionController,
                        prefixIcon: Icon(Icons.work_outline, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Batch Year',
                        hint: 'e.g. 2024',
                        controller: _batchYearController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                    const Expanded(child: SizedBox()), 
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                Text('Skills', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Separate skills by commas (e.g. Flutter, Dart, Firebase)',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  label: 'Your Skills',
                  controller: _skillsController,
                  prefixIcon: Icon(Icons.code_rounded, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: AppSizes.xxl),

                if (widget.user.role == UserRole.alumni) ...[
                  Text('Mentorship', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: SwitchListTile.adaptive(
                      title: Text(
                        'Open to Mentoring',
                        style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        'Allow students to send you mentorship requests.',
                        style: AppTextStyles.caption.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      value: _isAvailableForMentoring,
                      activeThumbColor: colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onChanged: (val) {
                        setState(() {
                          _isAvailableForMentoring = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),
                ],

                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Save Changes',
                      onPressed: _onSave,
                      isLoading: state is ProfileUpdating,
                    );
                  },
                ),
                const SizedBox(height: AppSizes.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
