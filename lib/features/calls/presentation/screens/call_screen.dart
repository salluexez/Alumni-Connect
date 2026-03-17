import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallEnded) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is CallIncoming) {
          return _IncomingCallView(call: state.call);
        } else if (state is CallOutgoing) {
          return _OutgoingCallView(call: state.call);
        } else if (state is CallActive) {
          return _ActiveCallView(state: state);
        } else if (state is CallError) {
          return Scaffold(
            body: Center(
              child: Text(state.message, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _IncomingCallView extends StatelessWidget {
  final dynamic call;
  const _IncomingCallView({required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            ProfileAvatar(imageUrl: call.callerPhoto, size: 120, name: call.callerName),
            const SizedBox(height: AppSizes.xl),
            Text(call.callerName, style: AppTextStyles.h1.copyWith(color: Colors.white)),
            Text('Incoming Voice Call', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70)),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxxl, vertical: AppSizes.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _CallActionButton(
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onPressed: () => context.read<CallCubit>().declineCall(call),
                    label: 'Decline',
                  ),
                  _CallActionButton(
                    icon: Icons.call_rounded,
                    color: AppColors.success,
                    onPressed: () => context.read<CallCubit>().acceptCall(call),
                    label: 'Accept',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xxxl),
          ],
        ),
      ),
    );
  }
}

class _OutgoingCallView extends StatelessWidget {
  final dynamic call;
  const _OutgoingCallView({required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            ProfileAvatar(imageUrl: call.receiverPhoto, size: 120, name: call.receiverName),
            const SizedBox(height: AppSizes.xl),
            Text(call.receiverName, style: AppTextStyles.h1.copyWith(color: Colors.white)),
            Text('Calling...', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70)),
            const Spacer(flex: 3),
            _CallActionButton(
              icon: Icons.call_end_rounded,
              color: AppColors.error,
              onPressed: () => context.read<CallCubit>().endCall(call),
              label: 'End Call',
            ),
            const SizedBox(height: AppSizes.xxxl),
          ],
        ),
      ),
    );
  }
}

class _ActiveCallView extends StatelessWidget {
  final CallActive state;
  const _ActiveCallView({required this.state});

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final call = state.call;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            ProfileAvatar(imageUrl: call.receiverPhoto, size: 120, name: call.receiverName),
            const SizedBox(height: AppSizes.xl),
            Text(call.receiverName, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            const SizedBox(height: AppSizes.sm),
            Text(_formatDuration(state.duration), style: AppTextStyles.h4.copyWith(color: Colors.white70)),
            const Spacer(flex: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xxl),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallControlTile(
                      icon: state.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: 'Mute',
                      isActive: state.isMuted,
                      onTap: () => context.read<CallCubit>().toggleMute(),
                    ),
                    _CallControlTile(
                      icon: Icons.call_end_rounded,
                      label: 'End',
                      color: AppColors.error,
                      onTap: () => context.read<CallCubit>().endCall(call),
                    ),
                    _CallControlTile(
                      icon: state.isSpeakerPhone ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                      label: 'Speaker',
                      isActive: state.isSpeakerPhone,
                      onTap: () => context.read<CallCubit>().toggleSpeaker(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String label;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _CallControlTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  const _CallControlTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : (color ?? Colors.white.withValues(alpha: 0.1)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
