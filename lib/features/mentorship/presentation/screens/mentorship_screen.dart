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
import '../../domain/entities/mentorship_entity.dart';
import '../cubit/mentorship_cubit.dart';
import '../cubit/mentorship_state.dart';

class MentorshipScreen extends StatefulWidget {
  const MentorshipScreen({super.key});

  @override
  State<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends State<MentorshipScreen> {
  late bool _isAlumni;

  @override
  void initState() {
    super.initState();
    final role = (context.read<AuthBloc>().state as AuthAuthenticated).user.role.name;
    _isAlumni = role == 'alumni';
    context.read<MentorshipCubit>().loadRequests(asMentor: _isAlumni);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentorship Hub', style: AppTextStyles.h3),
      ),
      body: BlocConsumer<MentorshipCubit, MentorshipState>(
        listener: (context, state) {
          if (state is MentorshipActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is MentorshipError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is MentorshipLoading || state is MentorshipInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is MentorshipLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return EmptyState(
                icon: Icons.school_outlined,
                title: 'No Mentorship Requests',
                subtitle: _isAlumni
                    ? 'You have no pending mentorship requests from students.'
                    : 'You haven\'t requested any mentorship yet. Find mentors in the directory.',
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<MentorshipCubit>().loadRequests(asMentor: _isAlumni),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSizes.md),
                itemBuilder: (context, index) => _MentorshipCard(
                  request: requests[index],
                  isAlumni: _isAlumni,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MentorshipCard extends StatelessWidget {
  final MentorshipRequestEntity request;
  final bool isAlumni;

  const _MentorshipCard({required this.request, required this.isAlumni});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'pending' => AppColors.warning,
      'accepted' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.textHint,
    };

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAlumni ? request.menteeName : 'Request to Mentor',
                style: AppTextStyles.h4,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(request.subject, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSizes.sm),
          Text(request.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.lg),
          Text('Sent ${timeago.format(request.createdAt)}', style: AppTextStyles.caption),
          
          if (isAlumni && request.status == 'pending') ...[
            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.read<MentorshipCubit>().respondToRequest(request.id, 'rejected'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.read<MentorshipCubit>().respondToRequest(request.id, 'accepted'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
