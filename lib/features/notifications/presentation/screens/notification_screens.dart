import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';

import '../cubit/notification_cubit.dart';

class NotificationsInboxScreen extends StatelessWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(sl())..load(),
      child: const _InboxView(),
    );
  }
}

class _InboxView extends StatelessWidget {
  const _InboxView();

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('التنبيهات'),
        toolbarHeight: 76,
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllRead(),
            child: const Text('قراءة الكل'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.items.isEmpty) {
            return StatusView.error(
              body: state.error!,
              onAction: () => context.read<NotificationCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return const StatusView.empty(
              title: 'لا تنبيهات',
              body: 'ستظهر هنا تنبيهات التصميم والعروض والطلبات.',
            );
          }
          return IvorySheet(
            child: RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final n = state.items[i];
                  return Material(
                    color: n.isRead
                        ? c.raised
                        : c.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight:
                              n.isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(n.body),
                      trailing: n.isRead
                          ? null
                          : Icon(Icons.circle, size: 10, color: c.teal),
                      onTap: () async {
                        if (!n.isRead) {
                          await context
                              .read<NotificationCubit>()
                              .markRead(n.id);
                        }
                        final route = n.route;
                        if (route != null && context.mounted) {
                          context.push(route);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
