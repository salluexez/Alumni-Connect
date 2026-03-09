import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/alumni_cubit.dart';
import '../cubit/alumni_state.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AlumniCubit>().fetchAlumni();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.alumniDirectory, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.sm,
              AppSizes.screenPadding,
              AppSizes.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) =>
                  context.read<AlumniCubit>().searchAlumni(query),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: AppStrings.searchAlumni,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: AppSizes.iconMd),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textHint, size: AppSizes.iconMd),
                        onPressed: () {
                          _searchController.clear();
                          context.read<AlumniCubit>().fetchAlumni();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── List ────────────────────────────────────────
          Expanded(
            child: BlocBuilder<AlumniCubit, AlumniState>(
              builder: (context, state) {
                if (state is AlumniLoading || state is AlumniInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is AlumniError) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Failed to load',
                    subtitle: state.message,
                    actionLabel: 'Retry',
                    onAction: () => context.read<AlumniCubit>().fetchAlumni(),
                  );
                }
                if (state is AlumniLoaded) {
                  if (state.alumni.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: AppStrings.noAlumniFound,
                      subtitle: 'Try a different search or filter',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding,
                      vertical: AppSizes.sm,
                    ),
                    itemCount: state.alumni.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, index) => AlumniCard(
                      user: state.alumni[index],
                      onTap: () =>
                          context.push('/alumni/${state.alumni[index].uid}'),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ── Alumni Card ───────────────────────────────────────────
class AlumniCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const AlumniCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              imageUrl: user.photoUrl,
              name: user.name,
              size: AppSizes.avatarMd,
              backgroundColor: _getAvatarColor(user.name),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTextStyles.h4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isAvailableForMentoring)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            'Mentoring',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  if (user.position != null || user.company != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [user.position, user.company]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' @ '),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (user.batchYear != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 3),
                        Text('Batch ${user.batchYear}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                  if (user.skills.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    SizedBox(
                      height: 22,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            user.skills.length > 3 ? 3 : user.skills.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSizes.xs),
                        itemBuilder: (context, i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                            border: Border.all(
                                color: AppColors.border, width: 0.5),
                          ),
                          child: Text(
                            user.skills[i],
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: AppSizes.iconMd),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFEC4899),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

// ── Filter Sheet ──────────────────────────────────────────
class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(AppStrings.filterBy, style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.lg),
          Text(AppStrings.batchYear, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            children: [2024, 2023, 2022, 2021, 2020, 2019, 2018]
                .map((y) => ChoiceChip(
                      label: Text('$y'),
                      selected: false,
                      onSelected: (_) {},
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}
