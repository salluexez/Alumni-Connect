import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';
import '../../../alumni_directory/domain/repositories/connection_repository.dart';
import '../../../alumni_directory/data/models/connection_request_model.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  final ConnectionRepository _connectionRepository;
  StreamSubscription? _subscription;

  NotificationCubit({
    required NotificationRepository repository,
    required ConnectionRepository connectionRepository,
  })  : _repository = repository,
        _connectionRepository = connectionRepository,
        super(const NotificationInitial());

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void loadUserNotifications() {
    emit(const NotificationLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const NotificationError('User not authenticated'));
      return;
    }

    _subscription?.cancel();
    _subscription = _repository.getUserNotifications(uid).listen((result) {
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (notifications) {
          final unreadCount = notifications.where((n) => !n.isRead).length;
          emit(NotificationsLoaded(notifications: notifications, unreadCount: unreadCount));
        },
      );
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
    // UI updates automatically via stream
  }

  Future<void> markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _repository.markAllAsRead(uid);
    }
  }

  Future<void> respondToConnectionRequest(String requestId, String notificationId, ConnectionStatus status) async {
    try {
      await _connectionRepository.updateConnectionStatus(
        requestId, 
        status, 
        notificationId: notificationId,
      );
    } catch (e) {
      // Don't emit state-wide error, as it replaces the entire notification list.
      // Instead, we could have an ErrorStream or just rely on the UI's try-catch.
      rethrow;
    }
  }
}
