import 'package:flutter/material.dart';
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
          path: RouteNames.jobs,
          name: 'jobs',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<JobsCubit>(),
            child: const JobsScreen(),
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


// ── Main Shell with Material 3 Bottom Nav ────────────────
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getIndex(location),
        onDestinationSelected: (index) => _onNavTap(context, index),
        backgroundColor: const Color(0xFF1E293B),
        indicatorColor: const Color(0xFF2463EB).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Directory'),
          NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work_rounded),
              label: 'Jobs'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }

  int _getIndex(String path) {
    if (path.startsWith(RouteNames.alumniDirectory)) return 1;
    if (path.startsWith(RouteNames.jobs)) return 2;
    if (path.startsWith(RouteNames.inbox)) return 3;
    if (path.startsWith(RouteNames.profile)) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.alumniDirectory);
      case 2:
        context.go(RouteNames.jobs);
      case 3:
        context.go(RouteNames.inbox);
      case 4:
        context.go(RouteNames.profile);
    }
  }
}
