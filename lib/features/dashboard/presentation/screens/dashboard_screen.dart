import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../navigation/route_names.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../domain/entities/activity_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const _DashboardShimmer();
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardBody(
              user: state.user, 
              stats: state.stats,
              activities: state.activities,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Dashboard Body ────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  final UserEntity user;
  final Map<String, int> stats;
  final List<ActivityEntity> activities;
  
  const _DashboardBody({
    required this.user, 
    required this.stats,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ───────────────────────────────────────
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A2740), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding, 60, AppSizes.screenPadding, 0),
              child: Row(
                children: [
                  ProfileAvatar(
                    imageUrl: user.photoUrl,
                    name: user.name,
                    size: 56,
                    showBorder: true,
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome back 👋',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(user.name, style: AppTextStyles.h3),
                        const SizedBox(height: 2),
                        _RoleBadge(role: user.role),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () => context.push(RouteNames.notifications),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats Row ───────────────────────────
                Row(
                  children: [
                    _StatCard(
                      label: 'Connections',
                      value: '${stats['connections'] ?? 0}',
                      icon: Icons.people_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    _StatCard(
                      label: 'Mentors',
                      value: '${stats['mentors'] ?? 0}',
                      icon: Icons.school_outlined,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    _StatCard(
                      label: 'Jobs',
                      value: '${stats['jobs'] ?? 0}',
                      icon: Icons.work_outline,
                      color: AppColors.warning,
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Quick Actions ────────────────────────
                Text('Quick Actions', style: AppTextStyles.h3),
                const SizedBox(height: AppSizes.lg),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSizes.sm,
                  mainAxisSpacing: AppSizes.sm,
                  childAspectRatio: 2.2,
                  children: [
                    _QuickActionCard(
                      label: 'Find Alumni',
                      icon: Icons.search_rounded,
                      gradient: AppColors.primaryGradient,
                      onTap: () => context.go(RouteNames.alumniDirectory),
                    ),
                    _QuickActionCard(
                      label: 'Browse Jobs',
                      icon: Icons.work_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF047857)],
                      ),
                      onTap: () => context.go(RouteNames.jobs),
                    ),
                    _QuickActionCard(
                      label: 'Find Mentor',
                      icon: Icons.school_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                      ),
                      onTap: () => context.go(RouteNames.mentorship),
                    ),
                    _QuickActionCard(
                      label: 'Messages',
                      icon: Icons.chat_bubble_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFB45309)],
                      ),
                      onTap: () => context.go(RouteNames.inbox),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Profile Completion Banner ────────────
                if (user.bio == null || user.bio!.isEmpty)
                  _ProfileCompletionBanner(
                    onTap: () => context.go(RouteNames.profile),
                  ),

                const SizedBox(height: AppSizes.xxl),

                // ── Recent Activity ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: AppTextStyles.h3),
                    TextButton(
                      onPressed: () {},
                      child: Text('See all',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                if (activities.isEmpty)
                  _ActivityItem(
                    icon: Icons.info_outline,
                    color: AppColors.textHint,
                    title: 'No recent activity',
                    subtitle: 'Your recent actions will appear here.',
                    time: '',
                  )
                else
                  ...activities.map<Widget>((a) => _ActivityItem(
                    icon: _getActivityIcon(a.type),
                    color: _getActivityColor(a.type),
                    title: a.title,
                    subtitle: a.subtitle,
                    time: _formatTime(a.createdAt),
                  )),

                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    return switch (type) {
      'connection' => Icons.person_add_outlined,
      'mentorship' => Icons.school_outlined,
      'job' => Icons.work_outline,
      _ => Icons.notifications_none_outlined,
    };
  }

  Color _getActivityColor(String type) {
    return switch (type) {
      'connection' => AppColors.primary,
      'mentorship' => AppColors.success,
      'job' => AppColors.warning,
      _ => AppColors.textHint,
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

// ── Role Badge ────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      UserRole.alumni => AppColors.alumniBadge,
      UserRole.admin => AppColors.adminBadge,
      UserRole.student => AppColors.studentBadge,
    };
    final label = switch (role) {
      UserRole.alumni => 'Alumni',
      UserRole.admin => 'Admin',
      UserRole.student => 'Student',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppSizes.iconMd),
            const SizedBox(height: AppSizes.xs),
            Text(value, style: AppTextStyles.h2.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _QuickActionCard({required this.label, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppSizes.iconMd),
            const SizedBox(width: AppSizes.sm),
            Text(label,
                style: AppTextStyles.labelLarge
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Profile Completion Banner ─────────────────────────────
class _ProfileCompletionBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileCompletionBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF1E293B)],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 32),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complete your profile', style: AppTextStyles.h4),
                  Text(
                    'Add bio, skills & photo to get noticed',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Activity Item ─────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  const _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconMd),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (time.isNotEmpty)
            Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ── Shimmer Placeholder ───────────────────────────────────
class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
