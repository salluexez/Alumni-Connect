import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/cubit/chat_state.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/job_entity.dart';
import '../cubit/jobs_cubit.dart';
import '../cubit/jobs_state.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userRole = (context.read<AuthBloc>().state as AuthAuthenticated).user.role.name;
    final isAlumni = userRole == 'alumni';

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatRoomCreated) {
          context.pushNamed('chat', pathParameters: {'chatId': state.roomId});
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<JobsCubit, JobsState>(
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
                    title: Text('Community', style: AppTextStyles.h1.copyWith(color: colorScheme.onSurface)),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _showPostSheet(context, isAlumni),
                      icon: Icon(Icons.add_rounded, color: colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
                    child: Row(
                      children: [
                        _FilterButton(
                          label: 'All Posts',
                          isSelected: !_referralsOnly,
                          onTap: () => _toggleFilter(false),
                        ),
                        const SizedBox(width: 8),
                        _FilterButton(
                          label: 'Referrals',
                          isSelected: _referralsOnly,
                          onTap: () => _toggleFilter(true),
                        ),
                      ],
                    ),
                  ),
                ),

                if (state is JobsLoading || state is JobsInitial)
                  SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2)),
                  )
                else if (state is JobsError)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Sync failed',
                      subtitle: state.message,
                      actionLabel: 'Try Again',
                      onAction: () => context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly),
                    ),
                  )
                else if (state is JobsLoaded)
                  if (state.jobs.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.feed_rounded,
                        title: 'Nothing here yet',
                        subtitle: 'Shared opportunities appear here.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.md, AppSizes.screenPadding, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _PostCard(job: state.jobs[index]),
                          childCount: state.jobs.length,
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPostSheet(BuildContext context, bool isAlumni) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<JobsCubit>()),
          BlocProvider.value(value: context.read<AuthBloc>()),
        ],
        child: _CreatePostForm(
          isAlumni: isAlumni,
          onSuccess: () {
            Navigator.pop(sheetContext);
            context.read<JobsCubit>().loadJobs(referralsOnly: _referralsOnly);
          },
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CreatePostForm extends StatefulWidget {
  final bool isAlumni;
  final VoidCallback onSuccess;
  const _CreatePostForm({required this.isAlumni, required this.onSuccess});

  @override
  State<_CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<_CreatePostForm> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  bool _isReferral = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.paddingLg,
          AppSizes.screenPadding,
          keyboardPadding > 0 ? keyboardPadding + AppSizes.md : bottomPadding + AppSizes.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('New Post', style: AppTextStyles.h2.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: AppSizes.xl),
            
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Job Title',
                      hint: 'e.g. Flutter Developer',
                      controller: _titleController,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomTextField(
                      label: 'Company',
                      hint: 'Company Name',
                      controller: _companyController,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomTextField(
                      label: 'Location',
                      hint: 'Remote / City',
                      controller: _locationController,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomTextField(
                      label: 'Description',
                      hint: 'What is this role about?',
                      controller: _descController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Available for Referral', style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface)),
                                Text(
                                  'Check this if you can refer candidates directly.',
                                  style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _isReferral,
                            activeTrackColor: colorScheme.primary,
                            onChanged: (val) {
                              if (val && !widget.isAlumni) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Only Alumni can post referrals.')),
                                );
                                return;
                              }
                              setState(() => _isReferral = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'Share Post',
              onPressed: () {
                if (_titleController.text.isEmpty) return;
                final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
                final job = JobEntity(
                  id: DateTime.now().toString(),
                  title: _titleController.text,
                  company: _companyController.text,
                  location: _locationController.text,
                  type: 'Full-time',
                  description: _descController.text,
                  postedByUid: user.uid,
                  postedByName: user.name,
                  postedAt: DateTime.now(),
                  isReferral: _isReferral,
                );
                context.read<JobsCubit>().postJob(job);
                widget.onSuccess();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final JobEntity job;
  const _PostCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      opacity: 0.1,
      blur: 20,
      border: Border.all(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(size: 32, imageUrl: null, name: job.postedByName),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.postedByName, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface)),
                    Text(
                      timeago.format(job.postedAt),
                      style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              if (job.isReferral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.appColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text('Referral', 
                    style: AppTextStyles.labelSmall.copyWith(color: context.appColors.success)),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(job.title, style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(job.company, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
              Text(' • ${job.location}', style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            job.description,
            style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.lg),
          if (job.postType == 'referral' && job.postedByUid != (context.read<AuthBloc>().state as AuthAuthenticated).user.uid)
            Builder(
              builder: (context) {
                final authUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;
                final bool isInterested = job.interestedUserIds.contains(authUser.uid);
                
                return AppButton(
                  label: isInterested ? 'Interested' : 'I\'m Interested',
                  variant: isInterested ? AppButtonVariant.secondary : AppButtonVariant.glass,
                  onPressed: isInterested ? null : () {
                    context.read<JobsCubit>().expressInterest(
                      jobId: job.id,
                      applicantUid: authUser.uid,
                      interestData: {
                        'applicantName': authUser.name,
                        'applicantEmail': authUser.email,
                        'jobTitle': job.title,
                        'jobCompany': job.company,
                        'postedByUid': job.postedByUid,
                        'type': 'referral',
                      },
                    );
                    ScaffoldMessenger.of(context).clearSnackBars();
                    context.read<ChatCubit>().startChat(
                      job.postedByUid,
                      name: job.postedByName,
                      initialMessage: "Hi, I'm interested in this referral for ${job.title} at ${job.company}.",
                    );
                  },
                  height: 44,
                );
              }
            )
          else if (job.postType != 'referral')
            Builder(
              builder: (context) {
                final authUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;
                final isLiked = job.likedByUids.contains(authUser.uid);
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        label: job.likedByUids.isEmpty ? 'Like' : '${job.likedByUids.length}',
                        iconColor: isLiked ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.5),
                        textColor: isLiked ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.5),
                        onTap: () {
                          context.read<JobsCubit>().toggleLike(job.id, authUser.uid);
                        },
                      ),
                      const SizedBox(width: 24),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Comment',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comments Coming Soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _ActionButton({
    required this.icon, 
    required this.label, 
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: textColor ?? colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
