import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  Icon(Icons.error_outline, color: colorScheme.error, size: 48),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: 16),
            title: Text('Overview', style: AppTextStyles.displaySmall.copyWith(color: colorScheme.onSurface)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push(RouteNames.notifications),
              icon: Icon(Icons.notifications_rounded, color: colorScheme.onSurface),
            ),
            const SizedBox(width: 8),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome Header ────────────────────────
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    ProfileAvatar(
                      imageUrl: user.photoUrl,
                      name: user.name,
                      size: 60,
                      showBorder: true,
                    ),
                    const SizedBox(width: AppSizes.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', 
                              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                          Text(user.name.split(' ')[0], 
                              style: AppTextStyles.displaySmall.copyWith(color: colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxxl),

                // ── stats cards ──
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _StatItem(
                        label: 'Connections',
                        value: '${stats['connections'] ?? 0}',
                        icon: Icons.people_rounded,
                        color: colorScheme.primary,
                      ),
                      _StatItem(
                        label: 'Mentors',
                        value: '${stats['mentors'] ?? 0}',
                        icon: Icons.school_rounded,
                        color: Colors.greenAccent,
                      ),
                      _StatItem(
                        label: 'Postings',
                        value: '${stats['jobs'] ?? 0}',
                        icon: Icons.work_rounded,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xxxl),

                // ── Quick Explore Grid ───────────────────────
                Text('Explore Network', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                const SizedBox(height: AppSizes.lg),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSizes.md,
                  mainAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.4,
                  children: [
                    _ActionTile(
                      label: 'Directory',
                      icon: Icons.contacts_rounded,
                      color: colorScheme.tertiary,
                      onTap: () => context.go(RouteNames.alumniDirectory),
                    ),
                    _ActionTile(
                      label: 'Job Board',
                      icon: Icons.business_center_rounded,
                      color: Colors.greenAccent,
                      onTap: () => context.go(RouteNames.posts),
                    ),
                    _ActionTile(
                      label: 'Mentorship',
                      icon: Icons.psychology_rounded,
                      color: colorScheme.primary,
                      onTap: () => context.go(RouteNames.mentorship),
                    ),
                    _ActionTile(
                      label: 'Messages',
                      icon: Icons.chat_bubble_rounded,
                      color: Colors.orangeAccent,
                      onTap: () => context.go(RouteNames.inbox),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxxl),

                // ── Recent Activity ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                if (activities.isEmpty)
                  _ActivityItem(
                    icon: Icons.info_outline,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    title: 'No recent activity',
                    subtitle: 'Your updates will appear here.',
                    time: '',
                  )
                else
                  ...activities.take(3).map<Widget>((a) => _ActivityItem(
                    icon: _getActivityIcon(a.type),
                    color: _getActivityColor(context, a.type),
                    title: a.title,
                    subtitle: a.subtitle,
                    time: _formatTime(a.createdAt),
                  )),
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    return switch (type) {
      'connection' => Icons.person_add_rounded,
      'mentorship' => Icons.school_rounded,
      'job' => Icons.work_rounded,
      _ => Icons.notifications_none_rounded,
    };
  }

  Color _getActivityColor(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      'connection' => colorScheme.primary,
      'mentorship' => Colors.greenAccent,
      'job' => Colors.orangeAccent,
      _ => colorScheme.onSurface.withValues(alpha: 0.4),
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GlassContainer(
      width: 140,
      margin: const EdgeInsets.only(right: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      opacity: 0.1,
      blur: 20,
      border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1), width: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(value, style: AppTextStyles.h2.copyWith(color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSizes.lg),
        opacity: 0.1,
        blur: 20,
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1), width: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(label, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface)),
                Text(subtitle, 
                    style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (time.isNotEmpty)
            Text(time, style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
