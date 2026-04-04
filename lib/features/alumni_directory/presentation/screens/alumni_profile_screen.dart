import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../injection/injection.dart';
import '../cubit/connection_cubit.dart';
import '../cubit/alumni_cubit.dart';
import '../cubit/alumni_state.dart';
import '../../data/models/connection_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/widgets/theme_selector.dart';
import '../../../../navigation/route_names.dart';
import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/cubit/chat_state.dart';

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
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          if (state is ProfileError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to load profile',
              subtitle: state.message,
              actionLabel: 'Go back',
              onAction: () => context.canPop() ? context.pop() : null,
            );
          }
          final user = (state is ProfileLoaded)
              ? state.user
              : (state as ProfileUpdated).user;
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => getIt<ConnectionCubit>()
                  ..checkConnectionStatus(currentUserId ?? '', user.uid),
              ),
              BlocProvider(
                create: (context) => getIt<ChatCubit>(),
              ),
            ],
            child: BlocListener<ChatCubit, ChatState>(
              listener: (context, chatState) {
                if (chatState is ChatRoomCreated) {
                  context.push('${RouteNames.chat}/${chatState.roomId}');
                } else if (chatState is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(chatState.message)),
                  );
                }
              },
              child: _ProfileBody(user: user, isOwnProfile: false),
            ),
          );
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
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                )
              : null,
          actions: [
            if (isOwnProfile) ...[
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Profile Settings',
                onPressed: () =>
                    context.push(RouteNames.editProfile, extra: user).then((_) {
                  if (context.mounted) {
                    context.read<ProfileCubit>().loadProfile();
                  }
                }),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                tooltip: 'Logout',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
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
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
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
                  BlocBuilder<ConnectionCubit, ConnectionState>(
                    builder: (context, connState) {
                      final status = (connState is ConnectionStatusLoaded) 
                          ? connState.status 
                          : null;
                      
                      String label = 'Connect';
                      IconData icon = Icons.person_add_outlined;
                      AppButtonVariant variant = AppButtonVariant.secondary;
                      bool isLoading = connState is ConnectionLoading;
                      bool isEnabled = true;

                        if (status == ConnectionStatus.pending) {
                          label = 'Requested';
                          icon = Icons.access_time_rounded;
                          variant = AppButtonVariant.secondary;
                          isEnabled = false;
                        } else if (status == ConnectionStatus.accepted) {
                          label = 'Connected';
                          icon = Icons.check_circle_outline;
                          variant = AppButtonVariant.secondary;
                          isEnabled = false;
                        }

                      return Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Message',
                              onPressed: () {
                                context.read<ChatCubit>().startChat(
                                      user.uid,
                                      name: user.name,
                                      photoUrl: user.photoUrl,
                                    );
                              },
                              variant: AppButtonVariant.primary,
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: Colors.white,
                              ),
                              height: AppSizes.buttonHeightSm,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: AppButton(
                              label: label,
                              isLoading: isLoading,
                              onPressed: isEnabled ? () {
                                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                                final currentUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;
                                
                                if (currentUserId != null) {
                                  context.read<ConnectionCubit>().sendRequest(
                                    ConnectionRequestModel(
                                      id: '', // Will be generated by Firestore
                                      senderId: currentUserId,
                                      senderName: currentUser.name,
                                      senderPhotoUrl: currentUser.photoUrl,
                                      receiverId: user.uid,
                                      receiverName: user.name,
                                      status: ConnectionStatus.pending,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                }
                              } : null,
                              variant: variant,
                              icon: Icon(
                                icon,
                                size: 18,
                                color: variant == AppButtonVariant.secondary 
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              height: AppSizes.buttonHeightSm,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: AppSizes.xxl),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: AppSizes.lg),

                // ── Bio ─────────────────────────────────
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  Text('About', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    user.bio!,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
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
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            labelStyle: AppTextStyles.labelMedium,
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],

                // ── Contact / Social ─────────────────────
                Text('Contact', style: AppTextStyles.h3),
                const SizedBox(height: AppSizes.sm),
                _ContactRow(icon: Icons.email_outlined, label: user.email),
                
                if (isOwnProfile) ...[
                  const SizedBox(height: AppSizes.xxl),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: AppSizes.lg),
                  Text('App Theme', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.md),
                  const ThemeSelector(),
                ],

                const SizedBox(height: AppSizes.xxxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Logout', style: AppTextStyles.h3),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Theme.of(context).hintColor)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: Text('Logout',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
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
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = Colors.grey,
  });

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
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
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
          Icon(icon, size: AppSizes.iconMd, color: Theme.of(context).hintColor),
          const SizedBox(width: AppSizes.sm),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
