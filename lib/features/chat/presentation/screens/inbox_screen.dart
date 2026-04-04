import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../navigation/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/chat_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadUserRooms();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Messages', style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface)),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }
          if (state is ChatError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading chats',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<ChatCubit>().loadUserRooms(),
            );
          }
          if (state is ChatRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return const EmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No Messages Yet',
                subtitle: 'Connect with alumni to start chatting.',
              );
            }
            return ListView.separated(
              itemCount: state.rooms.length,
              separatorBuilder: (context, index) => Divider(
                color: colorScheme.outline.withValues(alpha: 0.1),
                height: 1,
                indent: AppSizes.screenPadding + 64,
              ),
              itemBuilder: (context, index) => _ChatRoomTile(room: state.rooms[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.alumniDirectory),
        backgroundColor: colorScheme.primary,
        elevation: 4,
        child: Icon(Icons.chat_rounded, color: colorScheme.onPrimary),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomEntity room;
  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUserId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    final otherUserId = room.participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
    final otherName = room.participantNames[otherUserId] ?? 'User';
    final otherPhoto = room.participantPhotos[otherUserId] ?? '';
    final unreadCount = room.unreadCounts[currentUserId] ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
      onTap: () => context.push('${RouteNames.chat}/${room.id}'),
      leading: ProfileAvatar(imageUrl: otherPhoto, size: 52, name: otherName, showBorder: unreadCount > 0),
      title: Text(
        otherName, 
        style: AppTextStyles.h4.copyWith(
          color: colorScheme.onSurface,
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        room.lastMessage.isEmpty ? 'Start a conversation' : room.lastMessage,
        style: AppTextStyles.bodyMedium.copyWith(
          color: unreadCount > 0 ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeago.format(room.lastMessageTime, locale: 'en_short'), 
            style: AppTextStyles.caption.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onPrimary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 10,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
