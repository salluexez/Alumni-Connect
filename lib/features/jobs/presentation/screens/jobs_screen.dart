import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/job_entity.dart';
import '../cubit/jobs_cubit.dart';
import '../cubit/jobs_state.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  bool _referralsOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly);
  }

  void _toggleFilter(bool value) {
    setState(() => _referralsOnly = value);
    context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly);
  }

  @override
  Widget build(BuildContext context) {
    final userRole = (context.read<AuthBloc>().state as AuthAuthenticated).user.role.name;
    final isAlumni = userRole == 'alumni';

    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs & Referrals', style: AppTextStyles.h3),
        actions: [
          if (isAlumni)
            IconButton(
              icon: const Icon(Icons.add_box_rounded),
              onPressed: () => _showPostJobSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Jobs'),
                  selected: !_referralsOnly,
                  onSelected: (val) { if (val) _toggleFilter(false); },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                FilterChip(
                  label: const Text('Referrals Only'),
                  selected: _referralsOnly,
                  onSelected: (val) { if (val) _toggleFilter(true); },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading || state is JobsInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state is JobsError) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Failed to load jobs',
                    subtitle: state.message,
                    actionLabel: 'Retry',
                    onAction: () => context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly),
                  );
                }
                if (state is JobsLoaded) {
                  if (state.jobs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.work_off_outlined,
                      title: 'No jobs found',
                      subtitle: 'Check back later for new opportunities',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.screenPadding),
                      itemCount: state.jobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.md),
                      itemBuilder: (context, index) => _JobCard(job: state.jobs[index]),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPostJobSheet(BuildContext context) {
    // simplified entry for now
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<JobsCubit>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSizes.screenPadding,
            right: AppSizes.screenPadding,
            top: AppSizes.screenPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post a Job / Referral', style: AppTextStyles.h3),
              const SizedBox(height: AppSizes.lg),
              // Simplified for brevity in agent step, normally full form
              const Text('Job form coming soon!'),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobEntity job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.textHint),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(job.company, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(job.location, style: AppTextStyles.caption),
                        const SizedBox(width: AppSizes.md),
                        const Icon(Icons.work_outline, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(job.type, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              if (job.isReferral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text('Referral Available', 
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            job.description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.lg),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   const CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(Icons.person, size: 16, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 8),
                  Text('Posted by ${job.postedByName}', style: AppTextStyles.caption),
                  const SizedBox(width: 8),
                  Text('• ${timeago.format(job.postedAt)}', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                ],
              ),
              AppButton(
                label: 'Apply',
                onPressed: () {},
                height: AppSizes.buttonHeightSm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
