import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/alumni_cubit.dart';
import '../cubit/alumni_state.dart';

class AlumniProfileScreen extends StatefulWidget {
  final String uid;
  const AlumniProfileScreen({super.key, required this.uid});

  @override
  State<AlumniProfileScreen> createState() => _AlumniProfileScreenState();
}

class _AlumniProfileScreenState extends State<AlumniProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load profile',
              subtitle: state.message,
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            );
          }
          final user = (state is ProfileLoaded)
              ? state.user
              : (state as ProfileUpdated).user;
          return _ProfileBody(user: user, isOwnProfile: false);
        },
      ),
    );
  }
}

// ── My Profile Screen ─────────────────────────────────────
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load profile',
              subtitle: state.message,
            );
          }
          final user = switch (state) {
            ProfileLoaded s => s.user,
            ProfileUpdated s => s.user,
            ProfileUpdating s => s.user,
            _ => null,
          };
          if (user == null) return const SizedBox.shrink();
          return _ProfileBody(user: user, isOwnProfile: true);
        },
      ),
    );
  }
}

// ── Shared Profile Body ───────────────────────────────────
class _ProfileBody extends StatelessWidget {
  final UserEntity user;
  final bool isOwnProfile;
  const _ProfileBody({required this.user, required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── SliverAppBar with Cover ───────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (isOwnProfile)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditDialog(context),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Avatar positioned at bottom
                Positioned(
                  bottom: 16,
                  left: AppSizes.screenPadding,
                  child: ProfileAvatar(
                    imageUrl: user.photoUrl,
                    name: user.name,
                    size: 80,
                    showBorder: true,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name & Role ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AppTextStyles.h1),
                          if (user.position != null || user.company != null)
                            Text(
                              [user.position, user.company]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(' @ '),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    _RolePill(role: user.role),
                  ],
                ),

                // ── Badges ──────────────────────────────
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    if (user.batchYear != null)
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Batch ${user.batchYear}',
                      ),
                    if (user.isAvailableForMentoring) ...[
                      const SizedBox(width: AppSizes.sm),
                      _InfoChip(
                        icon: Icons.school_outlined,
                        label: 'Open to Mentoring',
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Action Buttons ───────────────────────
                if (!isOwnProfile)
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Message',
                          onPressed: () {},
                          variant: AppButtonVariant.primary,
                          icon: const Icon(Icons.chat_bubble_outline,
                              size: 18, color: Colors.white),
                          height: AppSizes.buttonHeightSm,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Request Mentorship',
                          onPressed: () {},
                          variant: AppButtonVariant.secondary,
                          height: AppSizes.buttonHeightSm,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: AppSizes.xxl),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSizes.lg),

                // ── Bio ─────────────────────────────────
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  Text('About', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.sm),
                  Text(user.bio!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                  const SizedBox(height: AppSizes.lg),
                ],

                // ── Skills ───────────────────────────────
                if (user.skills.isNotEmpty) ...[
                  Text('Skills', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.xs,
                    children: user.skills
                        .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.surfaceVariant,
                              labelStyle: AppTextStyles.labelMedium,
                              side: const BorderSide(
                                  color: AppColors.border, width: 0.5),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // ── Contact / Social ─────────────────────
                Text('Contact', style: AppTextStyles.h3),
                const SizedBox(height: AppSizes.sm),
                _ContactRow(icon: Icons.email_outlined, label: user.email),

                const SizedBox(height: AppSizes.xxxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────
class _RolePill extends StatelessWidget {
  final UserRole role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      UserRole.alumni => (AppColors.alumniBadge, 'Alumni'),
      UserRole.admin => (AppColors.adminBadge, 'Admin'),
      UserRole.student => (AppColors.studentBadge, 'Student'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(
              color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, this.color = AppColors.textHint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textHint),
          const SizedBox(width: AppSizes.sm),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
