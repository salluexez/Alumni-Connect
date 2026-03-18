import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: AppTextStyles.h3),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
              separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 1),
              itemBuilder: (context, index) => _ChatRoomTile(room: state.rooms[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.alumniDirectory),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomEntity room;
  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final currentUserId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    final otherUserId = room.participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
    final otherName = room.participantNames[otherUserId] ?? 'User';
    final otherPhoto = room.participantPhotos[otherUserId] ?? '';
    final unreadCount = room.unreadCounts[currentUserId] ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
      onTap: () => context.push('${RouteNames.chat}/${room.id}'),
      leading: ProfileAvatar(imageUrl: otherPhoto, size: 48, name: otherName),
      title: Text(otherName, style: AppTextStyles.h4),
      subtitle: Text(
        room.lastMessage.isEmpty ? 'Start a conversation' : room.lastMessage,
        style: AppTextStyles.bodyMedium.copyWith(
          color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeago.format(room.lastMessageTime, locale: 'en_short'), style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
