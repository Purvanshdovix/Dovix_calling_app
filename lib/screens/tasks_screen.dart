import 'package:flutter/material.dart';

import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'lead_details_screen.dart';
import '../widgets/app_icon.dart';

/// (tile icon, tile colour, tile bg, action icon, action colour) per task, following the design.
(AppIcons, Color, Color, AppIcons, Color) _style(TaskItem t) => switch (t.kind) {
  TaskKind.call when t.category == TaskCategory.followUp => (
    AppIcons.wifiCall,
    AppColors.green,
    AppColors.greenSoft,
    AppIcons.phone,
    AppColors.primary,
  ),
  TaskKind.call => (AppIcons.contactCard, AppColors.primary, AppColors.primarySoft, AppIcons.phone, AppColors.green),
  TaskKind.whatsapp => (
    AppIcons.whatsapp,
    AppColors.whatsapp,
    AppColors.greenSoft,
    AppIcons.whatsapp,
    AppColors.whatsapp,
  ),
  TaskKind.email => (AppIcons.email, AppColors.purple, AppColors.purpleSoft, AppIcons.email, AppColors.primary),
  TaskKind.meeting => (AppIcons.company, AppColors.orange, AppColors.orangeSoft, AppIcons.video, AppColors.primary),
};

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskCategory? _filter; // null = All
  bool _showDone = false;

  void _act(TaskItem t) {
    final lead = AppScope.read(context).leadById(t.leadId);
    if (lead == null) return showToast(context, 'No contact linked to this task');
    switch (t.kind) {
      case TaskKind.call:
        startCall(context, leadId: lead.id, name: lead.name, phone: lead.phone, company: lead.company);
      case TaskKind.whatsapp:
        openWhatsApp(context, lead.phone);
      case TaskKind.email:
        openEmail(context, lead.email);
      case TaskKind.meeting:
        showToast(context, 'Meeting link sent to ${lead.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final pending = store.tasks.where((t) => !t.done);
    int count(TaskCategory? c) => pending.where((t) => c == null || t.category == c).length;
    final now = DateTime.now();
    final list = store.tasks.where((t) => (_filter == null || t.category == _filter) && (_showDone || !t.done)).toList()
      ..sort((a, b) => a.done != b.done ? (a.done ? 1 : -1) : a.due.compareTo(b.due));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          PageHeader(
            title: "Today's Tasks (${pending.length})",
            trailing: [
              IconButton(
                tooltip: 'Options',
                icon: AppIcon(AppIcons.sliders, color: _showDone ? AppColors.primary : AppColors.text),
                onPressed: () => showAppSheet<void>(
                  context,
                  title: 'Tasks',
                  children: (ctx) => [
                    SheetOption(
                      icon: _showDone ? AppIcons.eyeOff : AppIcons.eye,
                      label: _showDone ? 'Hide completed tasks' : 'Show completed tasks',
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _showDone = !_showDone);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Text(
                        'Tip: swipe a task left to mark it done.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilterChips<TaskCategory?>(
            value: _filter,
            onChanged: (f) => setState(() => _filter = f),
            items: [
              (null, 'All (${count(null)})'),
              (TaskCategory.followUp, 'Follow-ups (${count(TaskCategory.followUp)})'),
              (TaskCategory.callback, 'Callbacks (${count(TaskCategory.callback)})'),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const EmptyState(icon: AppIcons.check, title: 'All caught up!', subtitle: 'No tasks in this list'),
          if (list.isNotEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Column(children: [for (final t in list) _taskRow(t, store, now, last: t == list.last)]),
            ),
        ],
      ),
    );
  }

  Widget _taskRow(TaskItem t, AppStore store, DateTime now, {required bool last}) {
    final (icon, color, bg, action, actionColor) = _style(t);
    // Swipe left to complete (or reopen) — the design has no checkboxes.
    return Dismissible(
      key: ValueKey('task-${t.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        store.toggleTask(t.id);
        showToast(context, t.done ? 'Task completed' : 'Task reopened');
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.greenSoft,
        child: const AppIcon(AppIcons.check, color: AppColors.green),
      ),
      child: InkWell(
        onTap: t.leadId == null ? null : () => push(context, LeadDetailsScreen(leadId: t.leadId!)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundDecoration: last ? null : const IndentedDivider(60),
          child: Row(
            children: [
              IconTile(icon, color: color, bg: bg, size: 46, iconSize: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: t.done ? TextDecoration.lineThrough : null,
                        color: t.done ? AppColors.textLight : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(t.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(
                formatTime(t.due),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: t.done ? AppColors.textLight : AppColors.red,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: AppIcon(action, size: 21, color: t.done ? AppColors.textLight : actionColor),
                onPressed: t.done ? null : () => _act(t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
