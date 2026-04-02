import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/alumni_directory/presentation/cubit/alumni_cubit.dart';
import '../features/alumni_directory/presentation/screens/alumni_directory_screen.dart';
import '../features/alumni_directory/presentation/screens/alumni_profile_screen.dart';
import '../features/alumni_directory/presentation/screens/edit_profile_screen.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/jobs/presentation/cubit/jobs_cubit.dart';
import '../features/jobs/presentation/screens/jobs_screen.dart';
import '../features/mentorship/presentation/cubit/mentorship_cubit.dart';
import '../features/mentorship/presentation/screens/mentorship_screen.dart';
import '../features/chat/presentation/cubit/chat_cubit.dart';
import '../features/chat/presentation/screens/inbox_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/notifications/presentation/cubit/notification_cubit.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/admin/presentation/cubit/admin_cubit.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/calls/presentation/screens/call_screen.dart';
import '../injection/injection.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,
  debugLogDiagnostics: false,
  redirect: (context, state) => null,
  routes: [
    // ── Auth Routes ─────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),

    // ── Main Shell ──────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<DashboardCubit>(),
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.alumniDirectory,
          name: 'alumni_directory',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<AlumniCubit>(),
            child: const AlumniDirectoryScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.posts,
          name: 'posts',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<JobsCubit>()),
              BlocProvider(create: (_) => getIt<ChatCubit>()),
            ],
            child: const PostsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.inbox,
          name: 'inbox',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ChatCubit>(),
            child: const InboxScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.profile,
          name: 'profile',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ProfileCubit>(),
            child: const MyProfileScreen(),
          ),
        ),
      ],
    ),

    // ── Secondary Routes ────────────────────────────────
    GoRoute(
      path: '${RouteNames.alumniProfile}/:uid',
      name: 'alumni_profile',
      builder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return BlocProvider(
          create: (_) => getIt<ProfileCubit>(),
          child: AlumniProfileScreen(uid: uid),
        );
      },
    ),
    GoRoute(
      path: '${RouteNames.chat}/:chatId',
      name: 'chat',
      builder: (context, state) {
        final roomId = state.pathParameters['chatId']!;
        return BlocProvider(
          create: (_) => getIt<ChatCubit>(),
          child: ChatScreen(roomId: roomId),
        );
      },
    ),
    GoRoute(
      path: RouteNames.mentorship,
      name: 'mentorship',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MentorshipCubit>(),
        child: const MentorshipScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.notifications,
      name: 'notifications',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NotificationCubit>(),
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.adminDashboard,
      name: 'admin_dashboard',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AdminCubit>(),
        child: const AdminDashboardScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.editProfile,
      name: 'edit_profile',
      builder: (context, state) {
        final user = state.extra as UserEntity;
        return BlocProvider.value(
          value: getIt<ProfileCubit>(),
          child: EditProfileScreen(user: user),
        );
      },
    ),
    GoRoute(
      path: RouteNames.voiceCall,
      name: 'voice_call',
      builder: (context, state) => const CallScreen(),
    ),
  ],
);



class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final int selectedIndex = _getIndex(location);

    return Scaffold(
      extendBody: true, // Content should scroll behind blurred nav
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 90, // Increased for safe area
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.00),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.house_rounded,
                    label: 'Home',
                    isSelected: selectedIndex == 0,
                    onTap: () => _onNavTap(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.people_rounded,
                    label: 'Network',
                    isSelected: selectedIndex == 1,
                    onTap: () => _onNavTap(context, 1),
                  ),
                  _NavItem(
                    icon: Icons.feed_rounded,
                    label: 'Posts',
                    isSelected: selectedIndex == 2,
                    onTap: () => _onNavTap(context, 2),
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Inbox',
                    isSelected: selectedIndex == 3,
                    onTap: () => _onNavTap(context, 3),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Me',
                    isSelected: selectedIndex == 4,
                    onTap: () => _onNavTap(context, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

  int _getIndex(String path) {
    if (path.startsWith(RouteNames.alumniDirectory)) return 1;
    if (path.startsWith(RouteNames.posts)) return 2;
    if (path.startsWith(RouteNames.inbox)) return 3;
    if (path.startsWith(RouteNames.profile)) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(RouteNames.dashboard); break;
      case 1: context.go(RouteNames.alumniDirectory); break;
      case 2: context.go(RouteNames.posts); break;
      case 3: context.go(RouteNames.inbox); break;
      case 4: context.go(RouteNames.profile); break;
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                letterSpacing: 0.2,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
