import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/config/agora_config.dart';
import '../../data/datasources/call_remote_datasource.dart';
import '../../../chat/data/datasources/chat_remote_datasource.dart';
import '../../data/models/call_model.dart';
import '../../domain/entities/call_entity.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final CallRemoteDataSource _dataSource;
  final ChatRemoteDataSource _chatDataSource;
  RtcEngine? _engine;
  StreamSubscription? _callSubscription;
  Timer? _durationTimer;

  CallCubit({
    required CallRemoteDataSource dataSource,
    required ChatRemoteDataSource chatDataSource,
  })  : _dataSource = dataSource,
        _chatDataSource = chatDataSource,
        super(const CallInitial());

  @override
  Future<void> close() {
    _disposeEngine();
    _callSubscription?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }

  Future<void> _disposeEngine() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }

  // ── Call Actions ────────────────────────────────────────

  Future<void> startCall(CallModel call) async {
    emit(CallOutgoing(call));
    try {
      await _dataSource.startCall(call);
      _listenToCallStatus(call.id);
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> acceptCall(CallEntity call) async {
    try {
      await _dataSource.updateCallStatus(call.id, CallStatus.active);
      await _joinChannel(call.channelId);
      _startDurationTimer();
      emit(CallActive(call: call));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> declineCall(CallEntity call) async {
    try {
      await _dataSource.updateCallStatus(call.id, CallStatus.declined);
      
      final sortedIds = [call.callerId, call.receiverId]..sort();
      final roomId = sortedIds.join('_');
      
      await _chatDataSource.saveCallLog(
        roomId: roomId,
        callerId: call.callerId,
        callStatus: 'declined',
        duration: 0,
      );
      
      emit(const CallEnded(message: 'Call declined'));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> endCall(CallEntity call) async {
    try {
      final activeState = state;
      int duration = 0;
      if (activeState is CallActive) {
        duration = activeState.duration;
      }

      await _dataSource.updateCallStatus(call.id, CallStatus.ended);
      await _disposeEngine();
      _durationTimer?.cancel();
      
      final sortedIds = [call.callerId, call.receiverId]..sort();
      final roomId = sortedIds.join('_');

      await _chatDataSource.saveCallLog(
        roomId: roomId,
        callerId: call.callerId,
        callStatus: 'ended',
        duration: duration,
      );

      emit(const CallEnded(message: 'Call ended'));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  // ── Firestore Signaling Listener ──────────────────────────

  void listenForIncomingCalls(String uid) {
    _callSubscription?.cancel();
    _callSubscription = _dataSource.getCallStream(uid).listen((call) {
      if (call != null) {
        if (call.status == CallStatus.dialing) {
          emit(CallIncoming(call));
        } else if (call.status == CallStatus.active && state is CallOutgoing) {
          _joinChannel(call.channelId);
          _startDurationTimer();
          emit(CallActive(call: call));
        } else if (call.status == CallStatus.ended || call.status == CallStatus.declined) {
          _disposeEngine();
          _durationTimer?.cancel();

          // If missed (never answered)
          if (state is CallIncoming) {
             final sortedIds = [call.callerId, call.receiverId]..sort();
             final roomId = sortedIds.join('_');
             _chatDataSource.saveCallLog(
               roomId: roomId,
               callerId: call.callerId,
               callStatus: 'missed',
               duration: 0,
             );
          }

          emit(const CallEnded());
        }
      }
    });
  }

  void _listenToCallStatus(String callId) {
    _callSubscription?.cancel();
    _callSubscription = _dataSource.getActiveCallStream(callId).listen((call) {
      if (call == null || call.status == CallStatus.ended || call.status == CallStatus.declined) {
        _disposeEngine();
        _durationTimer?.cancel();
        
        // If it was outgoing and stopped before active, it might be missed or declined
        if (state is CallOutgoing) {
           final sortedIds = [call!.callerId, call.receiverId]..sort();
           final roomId = sortedIds.join('_');
           _chatDataSource.saveCallLog(
             roomId: roomId,
             callerId: call.callerId,
             callStatus: call.status == CallStatus.declined ? 'declined' : 'missed',
             duration: 0,
           );
        }

        emit(const CallEnded());
      } else if (call.status == CallStatus.active && state is CallOutgoing) {
          _joinChannel(call.channelId);
          _startDurationTimer();
          emit(CallActive(call: call));
      }
    });
  }

  // ── Agora Engine & Channel Logic ─────────────────────────

  Future<void> _initEngine() async {
    if (_engine != null) return;

    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // Join success
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // User joined
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          final currentState = state;
          if (currentState is CallActive) {
            endCall(currentState.call);
          } else if (currentState is CallOutgoing) {
            endCall(currentState.call);
          }
        },
        onError: (err, msg) {
          // Agora Error
        },
      ),
    );

    await _engine!.enableAudio();
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
  }

  Future<void> _joinChannel(String channelId) async {
    await _initEngine();
    await _engine!.joinChannel(
      token: AgoraConfig.token,
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  // ── UI Control Toggles ───────────────────────────────────

  Future<void> toggleMute() async {
    if (state is CallActive) {
      final activeState = state as CallActive;
      final newMute = !activeState.isMuted;
      await _engine?.muteLocalAudioStream(newMute);
      emit(CallActive(
        call: activeState.call,
        isMuted: newMute,
        isSpeakerPhone: activeState.isSpeakerPhone,
        duration: activeState.duration,
      ));
    }
  }

  Future<void> toggleSpeaker() async {
    if (state is CallActive) {
      final activeState = state as CallActive;
      final newSpeaker = !activeState.isSpeakerPhone;
      await _engine?.setEnableSpeakerphone(newSpeaker);
      emit(CallActive(
        call: activeState.call,
        isMuted: activeState.isMuted,
        isSpeakerPhone: newSpeaker,
        duration: activeState.duration,
      ));
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is CallActive) {
        final activeState = state as CallActive;
        emit(CallActive(
          call: activeState.call,
          isMuted: activeState.isMuted,
          isSpeakerPhone: activeState.isSpeakerPhone,
          duration: activeState.duration + 1,
        ));
      }
    });
  }
}
