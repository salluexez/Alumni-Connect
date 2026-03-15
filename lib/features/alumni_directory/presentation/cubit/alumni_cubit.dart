import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'alumni_state.dart';

class AlumniCubit extends Cubit<AlumniState> {
  final UserRemoteDataSource _dataSource;

  AlumniCubit({required UserRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const AlumniInitial());

  Future<void> fetchAlumni({String? searchQuery}) async {
    emit(const AlumniLoading());
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final alumni = await _dataSource.getAlumniList(
        searchQuery: searchQuery,
        excludeUserId: currentUid,
        limit: 20,
      );
      emit(
        AlumniLoaded(
          alumni: alumni,
          hasMore: alumni.length == 20,
          searchQuery: searchQuery,
        ),
      );
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }

  Future<void> searchAlumni(String query) async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final alumni = await _dataSource.getAlumniList(
        searchQuery: query.isEmpty ? null : query,
        excludeUserId: currentUid,
        limit: 20,
      );
      emit(
        AlumniLoaded(
          alumni: alumni,
          hasMore: alumni.length == 20,
          searchQuery: query,
        ),
      );
    } catch (e) {
      emit(AlumniError(e.toString()));
    }
  }
}

// ── Profile Cubit ─────────────────────────────────────────
class ProfileCubit extends Cubit<ProfileState> {
  final UserRemoteDataSource _dataSource;

  ProfileCubit({required UserRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const ProfileInitial());

  Future<void> loadProfile({String? uid}) async {
    emit(const ProfileLoading());
    try {
      final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (targetUid == null) {
        emit(const ProfileError('Not authenticated'));
        return;
      }
      final user = await _dataSource.getUserById(targetUid);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(
    UserEntity user,
    Map<String, dynamic> updates,
  ) async {
    emit(ProfileUpdating(user));
    try {
      await _dataSource.updateUserProfile(user.uid, updates);
      final updated = await _dataSource.getUserById(user.uid);
      emit(ProfileUpdated(updated));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
