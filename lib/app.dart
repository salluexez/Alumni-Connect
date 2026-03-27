import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/calls/presentation/cubit/call_cubit.dart';
import 'features/calls/presentation/cubit/call_state.dart';
import 'injection/injection.dart';
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

class AlumniConnectApp extends StatelessWidget {
  const AlumniConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<CallCubit>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                appRouter.go(RouteNames.login);
              } else if (state is AuthAuthenticated) {
                context.read<CallCubit>().listenForIncomingCalls(state.user.uid);
              }
            },
          ),
          BlocListener<CallCubit, CallState>(
            listener: (context, state) {
              if (state is CallIncoming) {
                appRouter.push(RouteNames.voiceCall);
              }
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'Alumni Connect',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.themeFromPalette(themeState.palette),
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
