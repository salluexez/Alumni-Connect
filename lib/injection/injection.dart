import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../features/alumni_directory/data/datasources/connection_remote_datasource.dart';
import '../features/alumni_directory/data/datasources/user_remote_datasource.dart';
import '../features/alumni_directory/domain/repositories/connection_repository.dart';
import '../features/alumni_directory/presentation/cubit/alumni_cubit.dart';
import '../features/alumni_directory/presentation/cubit/connection_cubit.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/jobs/data/datasources/job_remote_datasource.dart';
import '../features/jobs/data/repositories/job_repository_impl.dart';
import '../features/jobs/domain/repositories/job_repository.dart';
import '../features/jobs/presentation/cubit/jobs_cubit.dart';
import '../features/mentorship/data/datasources/mentorship_remote_datasource.dart';
import '../features/mentorship/data/repositories/mentorship_repository_impl.dart';
import '../features/mentorship/domain/repositories/mentorship_repository.dart';
import '../features/mentorship/presentation/cubit/mentorship_cubit.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/presentation/cubit/chat_cubit.dart';
import '../features/calls/data/datasources/call_remote_datasource.dart';
import '../features/calls/presentation/cubit/call_cubit.dart';
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/presentation/cubit/notification_cubit.dart';
import '../features/admin/data/datasources/admin_remote_datasource.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/presentation/cubit/admin_cubit.dart';
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

  // ── Remote Data Sources ────────────────────────────
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<MentorshipRemoteDataSource>(
    () => MentorshipRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ConnectionRemoteDataSource>(
    () => ConnectionRemoteDataSource(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<CallRemoteDataSource>(
    () => CallRemoteDataSource(),
  );

  // ── Extra Repositories ────────────────────────────────
  getIt.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(getIt<JobRemoteDataSource>()),
  );
  getIt.registerLazySingleton<MentorshipRepository>(
    () => MentorshipRepositoryImpl(getIt<MentorshipRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<ChatRemoteDataSource>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(getIt<AdminRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(getIt<ConnectionRemoteDataSource>()),
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
  getIt.registerFactory<ConnectionCubit>(
    () => ConnectionCubit(repository: getIt<ConnectionRepository>()),
  );
  
  // ── Step 5 Cubits ──────────────────────────────────────
  getIt.registerFactory<JobsCubit>(
    () => JobsCubit(repository: getIt<JobRepository>()),
  );
  getIt.registerFactory<MentorshipCubit>(
    () => MentorshipCubit(repository: getIt<MentorshipRepository>()),
  );
  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(repository: getIt<ChatRepository>()),
  );
  
  // ── Step 6 Cubits ──────────────────────────────────────
  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(
      repository: getIt<NotificationRepository>(),
      connectionRepository: getIt<ConnectionRepository>(),
    ),
  );
  getIt.registerLazySingleton<CallCubit>(
    () => CallCubit(
      dataSource: getIt<CallRemoteDataSource>(),
      chatDataSource: getIt<ChatRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<AdminCubit>(
    () => AdminCubit(repository: getIt<AdminRepository>()),
  );
}
