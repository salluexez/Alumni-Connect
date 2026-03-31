import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../domain/entities/admin_stats_entity.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminCubit>().loadDashboardStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: AppTextStyles.h3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'User Management'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<AdminCubit>().loadDashboardStats();
              } else {
                context.read<AdminCubit>().searchUsers(_searchController.text);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(state),
              _buildUsersTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AdminState state) {
    if (state is AdminLoading && state is! AdminStatsLoaded) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    AdminDashboardStatsEntity? stats;
    if (state is AdminStatsLoaded) {
      stats = state.stats;
    }

    if (stats == null) {
      return const Center(child: Text('Load stats to see overview'));
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadDashboardStats(),
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          Text('System Overview', style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: stats.totalUsers.toString(),
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _StatCard(
                  title: 'Active Jobs',
                  value: stats.activeJobs.toString(),
                  icon: Icons.work_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Mentorships',
                  value: stats.totalMentorships.toString(),
                  icon: Icons.school_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Text('User Demographics', style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: stats.usersByRole.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: AppTextStyles.bodyMedium),
                      Text(entry.value.toString(), style: AppTextStyles.h4),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () => context.read<AdminCubit>().searchUsers(_searchController.text),
              ),
            ),
            onSubmitted: (value) => context.read<AdminCubit>().searchUsers(value),
          ),
        ),
        Expanded(
          child: _buildUsersList(state),
        ),
      ],
    );
  }

  Widget _buildUsersList(AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is AdminUsersLoaded) {
      if (state.users.isEmpty) {
        return const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No users found',
          subtitle: 'Try a different search term.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
        itemCount: state.users.length,
        separatorBuilder: (_, index) => const Divider(),
        itemBuilder: (context, index) {
          final user = state.users[index];
          return _UserListItem(user: user);
        },
      );
    }

    return const EmptyState(
      icon: Icons.admin_panel_settings_outlined,
      title: 'User Management',
      subtitle: 'Search for users to manage their access.',
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSizes.md),
          Text(value, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserEntity user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.name, style: AppTextStyles.h4),
      subtitle: Text('${user.role.name.toUpperCase()} • ${user.email}', style: AppTextStyles.caption),
      trailing: AppButton(
        label: user.isSuspended ? 'Reactivate' : 'Suspend',
        onPressed: () {
          context.read<AdminCubit>().suspendUser(user.uid, !user.isSuspended);
        },
        variant: user.isSuspended ? AppButtonVariant.primary : AppButtonVariant.secondary,
        height: 32,
      ),
    );
  }
}
