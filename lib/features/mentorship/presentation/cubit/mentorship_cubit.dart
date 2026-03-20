import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/mentorship_entity.dart';
import '../../domain/repositories/mentorship_repository.dart';
import 'mentorship_state.dart';

class MentorshipCubit extends Cubit<MentorshipState> {
  final MentorshipRepository _repository;

  MentorshipCubit({required MentorshipRepository repository})
      : _repository = repository,
        super(const MentorshipInitial());

  Future<void> loadRequests({bool asMentor = true}) async {
    emit(const MentorshipLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const MentorshipError('User not authenticated'));
      return;
    }
    
    final result = await _repository.getRequestsForUser(uid, asMentor: asMentor);
    result.fold(
      (failure) => emit(MentorshipError(failure.message)),
      (requests) => emit(MentorshipLoaded(requests)),
    );
  }

  Future<void> sendRequest(MentorshipRequestEntity request) async {
    emit(const MentorshipActionLoading());
    final result = await _repository.sendRequest(request);
    result.fold(
      (failure) => emit(MentorshipError(failure.message)),
      (_) => emit(const MentorshipActionSuccess('Request sent successfully')),
    );
  }

  Future<void> respondToRequest(String requestId, String status) async {
    emit(const MentorshipActionLoading());
    final result = await _repository.updateRequestStatus(requestId, status);
    result.fold(
      (failure) => emit(MentorshipError(failure.message)),
      (_) {
        emit(MentorshipActionSuccess('Request $status'));
        loadRequests(); // Reload list
      },
    );
  }
}
