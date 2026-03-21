import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../alumni_directory/data/models/connection_request_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is NotificationError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading notifications',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () => context.read<NotificationCubit>().loadUserNotifications(),
            );
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: 'You\'re all caught up!',
              );
            }
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final NotificationEntity notification;

  const _NotificationTile({required this.notification});

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _isResponding = false;
  String? _localStatus; // Optimistic status update

  @override
  void didUpdateWidget(_NotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear optimistic status once the real status arrives from stream
    if (widget.notification.status != null) {
      _localStatus = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (widget.notification.type) {
      case 'mentorship':
        icon = Icons.school_rounded;
        iconColor = AppColors.primary;
        break;
      case 'chat':
        icon = Icons.chat_bubble_rounded;
        iconColor = AppColors.success;
        break;
      case 'job':
        icon = Icons.work_rounded;
        iconColor = AppColors.warning;
        break;
      case 'connection_request':
        icon = Icons.person_add_rounded;
        iconColor = AppColors.primary;
        break;
      case 'connection_accepted':
        icon = Icons.handshake_rounded;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.textHint;
    }

    // Using widget.notification.status but falling back to _localStatus for real-time feedback
    final effectiveStatus = widget.notification.status ?? _localStatus;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
      tileColor: (widget.notification.isRead || effectiveStatus != null) ? Colors.transparent : AppColors.surfaceVariant.withValues(alpha: 0.5),
      onTap: () {
        if (!widget.notification.isRead) {
          context.read<NotificationCubit>().markAsRead(widget.notification.id);
        }
        
        switch (widget.notification.type) {
          case 'chat':
            if (widget.notification.relatedId != null) {
              context.pushNamed('chat', pathParameters: {'chatId': widget.notification.relatedId!});
            }
            break;
          case 'mentorship':
            context.pushNamed('mentorship');
            break;
          default:
            break;
        }
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        widget.notification.title,
        style: AppTextStyles.h4.copyWith(
          fontWeight: (widget.notification.isRead || effectiveStatus != null) ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            widget.notification.body,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            timeago.format(widget.notification.createdAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
          if (widget.notification.type == 'connection_request') ...[
            if (effectiveStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (effectiveStatus == 'accepted' 
                      ? AppColors.success 
                      : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: (effectiveStatus == 'accepted' 
                        ? AppColors.success 
                        : AppColors.error).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  effectiveStatus == 'accepted' 
                      ? '✓ Request Accepted' 
                      : '✕ Request Declined',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: effectiveStatus == 'accepted' 
                        ? AppColors.success 
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else if (!widget.notification.isRead) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Decline',
                      isLoading: _isResponding,
                      onPressed: _isResponding ? null : () async {
                        final cubit = context.read<NotificationCubit>();
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() {
                          _isResponding = true;
                          _localStatus = 'rejected';
                        });
                        try {
                          await cubit.respondToConnectionRequest(
                            widget.notification.relatedId ?? '',
                            widget.notification.id,
                            ConnectionStatus.rejected,
                          );
                        } catch (e) {
                          if (mounted) {
                            setState(() => _localStatus = null);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isResponding = false);
                        }
                      },
                      variant: AppButtonVariant.secondary,
                      height: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppButton(
                      label: 'Accept',
                      isLoading: _isResponding,
                      onPressed: _isResponding ? null : () async {
                        final cubit = context.read<NotificationCubit>();
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() {
                          _isResponding = true;
                          _localStatus = 'accepted';
                        });
                        try {
                          await cubit.respondToConnectionRequest(
                            widget.notification.relatedId ?? '',
                            widget.notification.id,
                            ConnectionStatus.accepted,
                          );
                        } catch (e) {
                          if (mounted) {
                            setState(() => _localStatus = null);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isResponding = false);
                        }
                      },
                      variant: AppButtonVariant.primary,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
      trailing: (widget.notification.isRead || effectiveStatus != null)
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
