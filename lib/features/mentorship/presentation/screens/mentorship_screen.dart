import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<MentorshipCubit, MentorshipState>(
        listener: (context, state) {
          if (state is MentorshipActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), 
                backgroundColor: context.appColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is MentorshipError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), 
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: 8),
                  title: Text('Mentorship', style: AppTextStyles.h1.copyWith(color: colorScheme.onSurface)),
                ),
              ),

              if (state is MentorshipLoading || state is MentorshipInitial)
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2)),
                )
              else if (state is MentorshipLoaded)
                if (state.requests.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.school_rounded,
                      title: 'Connect to grow',
                      subtitle: _isAlumni
                          ? 'Incoming requests will appear here.'
                          : 'Find mentors in the directory to start.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.md),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _MentorshipCard(
                          request: state.requests[index],
                          isAlumni: _isAlumni,
                        ),
                        childCount: state.requests.length,
                      ),
                    ),
                  )
              else
                const SliverFillRemaining(child: SizedBox.shrink()),
            ],
          );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = switch (request.status) {
      'pending' => context.appColors.warning,
      'accepted' => context.appColors.success,
      'rejected' => colorScheme.error,
      _ => colorScheme.onSurface.withValues(alpha: 0.4),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAlumni ? request.menteeName : 'Request sent',
                style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(request.subject, style: AppTextStyles.h4.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(
            request.message,
            style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            timeago.format(request.createdAt),
            style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          
          if (isAlumni && request.status == 'pending') ...[
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.read<MentorshipCubit>().respondToRequest(request.id, 'rejected'),
                    height: 40,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    onPressed: () => context.read<MentorshipCubit>().respondToRequest(request.id, 'accepted'),
                    height: 40,
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
