import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/chat_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../../calls/presentation/cubit/call_cubit.dart';
import '../../../calls/domain/entities/call_entity.dart';
import '../../../calls/data/models/call_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../navigation/route_names.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadMessages(widget.roomId);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String currentUserId, String currentUserName) {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final message = MessageEntity(
      id: '', 
      roomId: widget.roomId,
      senderId: currentUserId,
      text: text,
      sentAt: DateTime.now(),
    );

    context.read<ChatCubit>().sendMessage(message, currentUserName);
    _msgController.clear();
    _focusNode.requestFocus();
  }

  void _startVoiceCall(UserEntity currentUser, String otherId, String otherName, String otherPhoto) {
    final channelId = const Uuid().v4();
    final callId = '${currentUser.uid}_$otherId';

    final call = CallModel(
      id: callId,
      callerId: currentUser.uid,
      receiverId: otherId,
      callerName: currentUser.name,
      callerPhoto: currentUser.photoUrl ?? '',
      receiverName: otherName,
      receiverPhoto: otherPhoto,
      status: CallStatus.dialing,
      channelId: channelId,
      timestamp: DateTime.now(),
    );

    context.read<CallCubit>().startCall(call);
    context.push(RouteNames.voiceCall);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            String otherName = 'Chat';
            String otherPhoto = '';
            
            if (state is ChatMessagesLoaded) {
              final room = state.chatRoom;
              final otherId = room.participantIds.firstWhere((id) => id != currentUser.uid, orElse: () => '');
              otherName = room.participantNames[otherId] ?? 'User';
              otherPhoto = room.participantPhotos[otherId] ?? '';
            }
            
            return Row(
              children: [
                ProfileAvatar(imageUrl: otherPhoto, size: 36, name: otherName),
                const SizedBox(width: AppSizes.md),
                Text(otherName, style: AppTextStyles.h4.copyWith(color: colorScheme.onSurface)),
              ],
            );
          },
        ),
        titleSpacing: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
          onPressed: () {
            context.read<ChatCubit>().loadUserRooms();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.inbox);
            }
          }
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatMessagesLoaded) {
                final room = state.chatRoom;
                final otherId = room.participantIds.firstWhere((id) => id != currentUser.uid, orElse: () => '');
                final otherName = room.participantNames[otherId] ?? 'User';
                final otherPhoto = room.participantPhotos[otherId] ?? '';
                
                return IconButton(
                  icon: Icon(Icons.call_rounded, color: colorScheme.primary),
                  onPressed: () => _startVoiceCall(currentUser, otherId, otherName, otherPhoto),
                );
              }
              return const SizedBox.shrink();
            }
          ),
          const SizedBox(width: AppSizes.md),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading || state is ChatInitial) {
                  return Center(
                      child: CircularProgressIndicator(color: colorScheme.primary));
                }
                if (state is ChatMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, 
                              color: colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No messages yet', 
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.5))),
                          Text('Start the conversation!', 
                              style: AppTextStyles.caption.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.3))),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == currentUser.uid;
                      
                      if (msg.type == 'call') {
                        return _CallHistoryBubble(message: msg, isMe: isMe);
                      }
                      
                      return _MessageBubble(message: msg, isMe: isMe);
                    },
                  );
                }
                if (state is ChatError) {
                  return Center(
                      child: Text('Failed to load. ${state.message}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: colorScheme.error)));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPadding, vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                  top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1), width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      focusNode: _focusNode,
                      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.lg, vertical: AppSizes.md),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) =>
                          _sendMessage(currentUser.uid, currentUser.name),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded,
                          color: colorScheme.onPrimary, size: 20),
                      onPressed: () =>
                          _sendMessage(currentUser.uid, currentUser.name),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg).copyWith(
            bottomLeft: isMe ? const Radius.circular(AppSizes.radiusLg) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? colorScheme.onPrimary : colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(message.sentAt, locale: 'en_short'),
              style: AppTextStyles.caption.copyWith(
                color: (isMe ? colorScheme.onPrimary : colorScheme.onSurface).withValues(alpha: 0.5), 
                fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallHistoryBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const _CallHistoryBubble({required this.message, required this.isMe});

  String _formatDuration(int seconds) {
    if (seconds == 0) return '';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return ' (${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')})';
  }

  IconData _getIcon() {
    switch (message.callStatus) {
      case 'missed':
        return Icons.call_missed_rounded;
      case 'declined':
        return Icons.call_end_rounded;
      default:
        return isMe ? Icons.call_made_rounded : Icons.call_received_rounded;
    }
  }

  String _getStatusText() {
    switch (message.callStatus) {
      case 'missed':
        return 'Missed voice call';
      case 'declined':
        return 'Call declined';
      default:
        return '${isMe ? 'Outgoing' : 'Incoming'} voice call';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = message.callStatus == 'missed' ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.6);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(), size: 16, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${_getStatusText()}${_formatDuration(message.callDuration ?? 0)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeago.format(message.sentAt, locale: 'en_short'),
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
