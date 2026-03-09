import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../features/alumni_directory/data/datasources/user_remote_datasource.dart';
import '../features/alumni_directory/presentation/cubit/alumni_cubit.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();

/// Manual DI setup (without code generation for now)
void setupDependencies() {
  // ── Firebase ───────────────────────────────────────────
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // ── Auth Data Source ───────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  // ── Auth Repository ────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // ── Auth Use Cases ─────────────────────────────────────
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GoogleSignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // ── Auth BLoC ──────────────────────────────────────────
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      signUpUseCase: getIt<SignUpUseCase>(),
      googleSignInUseCase: getIt<GoogleSignInUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // ── User Remote Data Source ────────────────────────────
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );

  // ── Dashboard Cubit ────────────────────────────────────
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(dataSource: getIt<UserRemoteDataSource>()),
  );

  // ── Alumni & Profile Cubits ────────────────────────────
  getIt.registerFactory<AlumniCubit>(
    () => AlumniCubit(dataSource: getIt<UserRemoteDataSource>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(dataSource: getIt<UserRemoteDataSource>()),
  );
}
