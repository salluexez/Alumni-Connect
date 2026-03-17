import 'package:equatable/equatable.dart';
import '../../domain/entities/call_entity.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {
  const CallInitial();
}

class CallLoading extends CallState {
  const CallLoading();
}

class CallIncoming extends CallState {
  final CallEntity call;
  const CallIncoming(this.call);
  @override
  List<Object?> get props => [call];
}

class CallOutgoing extends CallState {
  final CallEntity call;
  const CallOutgoing(this.call);
  @override
  List<Object?> get props => [call];
}

class CallActive extends CallState {
  final CallEntity call;
  final bool isMuted;
  final bool isSpeakerPhone;
  final int duration; // in seconds
  const CallActive({
    required this.call,
    this.isMuted = false,
    this.isSpeakerPhone = false,
    this.duration = 0,
  });
  @override
  List<Object?> get props => [call, isMuted, isSpeakerPhone, duration];
}

class CallEnded extends CallState {
  final String? message;
  const CallEnded({this.message});
  @override
  List<Object?> get props => [message];
}

class CallError extends CallState {
  final String message;
  const CallError(this.message);
  @override
  List<Object?> get props => [message];
}
