import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocBuilder<AlumniCubit, AlumniState>(
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
                backgroundColor: colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding, vertical: 8),
                  title: Text('Directory',
                      style: AppTextStyles.h1.copyWith(color: colorScheme.onSurface)),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showFilterSheet(context),
                    icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── Search Bar ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) =>
                          context.read<AlumniCubit>().searchAlumni(query),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search by name, company, or skills',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: false, 
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────
              if (state is AlumniLoading || state is AlumniInitial)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (state is AlumniError)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Load failed',
                    subtitle: state.message,
                    actionLabel: 'Try Again',
                    onAction: () => context.read<AlumniCubit>().fetchAlumni(),
                  ),
                )
              else if (state is AlumniLoaded)
                if (state.alumni.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.people_rounded,
                      title: 'No results found',
                      subtitle: 'Try adjusting your search query.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.screenPadding, vertical: AppSizes.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final alumni = state.alumni[index];
                          return _AlumniListItem(
                            alumni: alumni,
                            onTap: () => context.push('/alumni/${alumni.uid}'),
                          );
                        },
                        childCount: state.alumni.length,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _AlumniListItem extends StatelessWidget {
  final UserEntity alumni;
  final VoidCallback onTap;

  const _AlumniListItem({required this.alumni, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              imageUrl: alumni.photoUrl,
              name: alumni.name,
              size: 50,
              backgroundColor: colorScheme.surfaceContainer,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(alumni.name,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: colorScheme.onSurface)),
                      if (alumni.isAvailableForMentoring) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary, 
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (alumni.company != null)
                    Text(
                      alumni.company!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  if (alumni.batchYear != null)
                    Text(
                      'Class of ${alumni.batchYear}',
                      style: AppTextStyles.caption
                          .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter', style: AppTextStyles.h3),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done')),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text('Batch Year', style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: 8,
            children: [2024, 2023, 2022, 2021, 2020].map((year) {
              return FilterChip(
                label: Text('$year'),
                onSelected: (_) {},
                backgroundColor: colorScheme.surfaceContainer,
                selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: colorScheme.onSurface),
                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
