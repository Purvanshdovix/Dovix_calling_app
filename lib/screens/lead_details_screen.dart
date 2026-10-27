import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';

const _tabs = ['Details', 'Activity', 'Notes', 'Files'];

DateTime _at(int daysFromNow, int hour) {
  final n = DateTime.now().add(Duration(days: daysFromNow));
  return DateTime(n.year, n.month, n.day, hour);
}

class LeadDetailsScreen extends StatefulWidget {
  const LeadDetailsScreen({super.key, required this.leadId});
  final String leadId;

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  String _tab = 'Details';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final lead = store.leadById(widget.leadId);
    if (lead == null) {
      return const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PageHeader(title: 'Lead', back: true),
              EmptyState(icon: AppIcons.profile, title: 'Lead not found'),
            ],
          ),
        ),
      );
    }

    void call() => startCall(context, leadId: lead.id, name: lead.name, phone: lead.phone, company: lead.company);
    void whatsapp() => openWhatsApp(context, lead.phone, text: 'Hi ${lead.name.split(' ').first},');
    void email() => openEmail(context, lead.email);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 24),
          children: [
            PageHeader(
              title: '',
              back: true,
              trailing: [IconButton(icon: const AppIcon(AppIcons.more), onPressed: () => _moreSheet(lead))],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Avatar(lead.name, size: 68, solid: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lead.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              children: [
                                // The design shows only the hot flag here; status lives in the More menu.
                                if (lead.hot)
                                  const Pill(
                                    'Hot Lead',
                                    icon: AppIcons.callRecord,
                                    fg: AppColors.red,
                                    bg: Color(0xFFFFE1E1),
                                  )
                                else
                                  GestureDetector(onTap: () => _statusSheet(lead), child: StatusPill(lead.status)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(lead.company, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _action(AppIcons.phone, 'Call', AppColors.green, AppColors.greenSoft, call),
                      _action(AppIcons.whatsapp, 'WhatsApp', AppColors.whatsapp, AppColors.greenSoft, whatsapp),
                      _action(AppIcons.email, 'Email', AppColors.primary, AppColors.primarySoft, email),
                      _action(AppIcons.more, 'More', AppColors.text, AppColors.input, () => _moreSheet(lead)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TabStrip(value: _tab, onChanged: (t) => setState(() => _tab = t)),
                  const SizedBox(height: 14),
                  ...switch (_tab) {
                    'Details' => _details(lead, call, email, whatsapp),
                    'Activity' => _activity(lead, store),
                    'Notes' => _notes(lead, store),
                    _ => _files(),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(AppIcons icon, String label, Color color, Color bg, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            IconCircle(icon, color: color, bg: bg, size: 48),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  List<Widget> _details(Lead lead, VoidCallback call, VoidCallback email, VoidCallback whatsapp) => [
    AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _InfoRow(icon: AppIcons.phone, text: lead.phone, action: _RowAction(AppIcons.phone, call)),
          _InfoRow(
            icon: AppIcons.email,
            text: lead.email.isEmpty ? '—' : lead.email,
            action: _RowAction(AppIcons.email, email),
          ),
          _InfoRow(icon: AppIcons.company, text: lead.company),
          _InfoRow(icon: AppIcons.globe, text: lead.website.isEmpty ? '—' : lead.website),
          _InfoRow(
            icon: AppIcons.location,
            label: 'Source',
            child: Pill(lead.source.label, fg: AppColors.primary, bg: AppColors.primarySoft),
          ),
          _InfoRow(
            icon: AppIcons.profile,
            label: 'Assigned to',
            onTap: () => _assignSheet(lead),
            child: Row(
              children: [
                if (lead.assignedTo.isNotEmpty) ...[Avatar(lead.assignedTo, size: 24), const SizedBox(width: 8)],
                Text(lead.assignedTo.isEmpty ? 'Unassigned' : lead.assignedTo, style: const TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
          _InfoRow(
            icon: AppIcons.clock,
            label: 'Last contact',
            text: lead.lastContact == null ? 'Never' : dayAndTime(lead.lastContact!),
          ),
        ],
      ),
    ),
    const SizedBox(height: 18),
    const Text('Next Follow-up', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
    const SizedBox(height: 10),
    Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const AppIcon(AppIcons.calendar, size: 16, color: AppColors.red),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    lead.nextFollowUp == null ? 'Not scheduled' : dayAndTime(lead.nextFollowUp!),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _reminderSheet(lead),
              child: const Text('Set Reminder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 18),
    Row(
      children: [
        Expanded(child: AppButton('Call Now', onPressed: call)),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton('Send WhatsApp', variant: ButtonVariant.outline, onPressed: whatsapp),
        ),
      ],
    ),
  ];

  List<Widget> _activity(Lead lead, AppStore store) {
    final items = <(DateTime, AppIcons, Color, String, String)>[
      for (final c in store.calls.where((c) => c.leadId == lead.id))
        (
          c.timestamp,
          switch (c.type) {
            CallType.missed => AppIcons.missedCall,
            CallType.incoming => AppIcons.incomingCall,
            CallType.outgoing => AppIcons.outgoingCall,
          },
          c.type == CallType.missed ? AppColors.red : AppColors.green,
          '${c.type.name[0].toUpperCase()}${c.type.name.substring(1)} call',
          c.type == CallType.missed ? 'Not answered' : 'Duration ${formatDuration(c.duration)}',
        ),
      for (final n in lead.notes) (n.createdAt, AppIcons.script, AppColors.purple, 'Note added', n.text),
    ]..sort((a, b) => b.$1.compareTo(a.$1));

    if (items.isEmpty) {
      return const [
        EmptyState(icon: AppIcons.activity, title: 'No activity yet', subtitle: 'Calls and notes will show up here'),
      ];
    }
    return [
      for (final (ts, icon, color, title, sub) in items)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              IconCircle(icon, color: color, bg: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(dayAndTime(ts), style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
          ),
        ),
    ];
  }

  List<Widget> _notes(Lead lead, AppStore store) => [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Write a note about this lead…',
              hintStyle: TextStyle(color: AppColors.textLight),
              border: InputBorder.none,
            ),
          ),
          AppButton(
            'Add Note',
            height: 40,
            onPressed: _note.text.trim().isEmpty
                ? null
                : () {
                    store.addNote(lead.id, _note.text.trim());
                    _note.clear();
                    showToast(context, 'Note added');
                  },
          ),
        ],
      ),
    ),
    if (lead.notes.isEmpty)
      const EmptyState(icon: AppIcons.script, title: 'No notes yet')
    else
      for (final n in lead.notes)
        AppCard(
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n.text, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 6),
              Text(dayAndTime(n.createdAt), style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
          ),
        ),
  ];

  List<Widget> _files() => [
    const EmptyState(
      icon: AppIcons.folder,
      title: 'No files attached',
      subtitle: 'Proposals and documents will appear here',
    ),
    AppButton(
      'Upload File',
      icon: AppIcons.export,
      variant: ButtonVariant.outline,
      onPressed: () => showToast(context, 'File uploads need the backend — coming soon'),
    ),
  ];

  void _moreSheet(Lead lead) {
    final store = AppScope.read(context);
    showAppSheet<void>(
      context,
      title: 'Lead actions',
      children: (ctx) => [
        SheetOption(
          icon: AppIcons.sort,
          label: 'Change status',
          onTap: () {
            Navigator.pop(ctx);
            _statusSheet(lead);
          },
        ),
        SheetOption(
          icon: AppIcons.userPlus,
          label: 'Reassign lead',
          onTap: () {
            Navigator.pop(ctx);
            _assignSheet(lead);
          },
        ),
        SheetOption(
          icon: AppIcons.flame,
          label: lead.hot ? 'Remove hot flag' : 'Mark as hot lead',
          onTap: () {
            store.updateLead(lead.id, (l) => l.hot = !l.hot);
            Navigator.pop(ctx);
          },
        ),
        SheetOption(
          icon: AppIcons.trophy,
          label: 'Mark as won',
          onTap: () {
            store.updateLead(
              lead.id,
              (l) => l
                ..status = LeadStatus.won
                ..isCustomer = true,
            );
            Navigator.pop(ctx);
            showToast(context, '${lead.name} marked as won 🎉');
          },
        ),
        SheetOption(
          icon: AppIcons.edit,
          label: 'Add note',
          onTap: () {
            Navigator.pop(ctx);
            setState(() => _tab = 'Notes');
          },
        ),
      ],
    );
  }

  Future<void> _statusSheet(Lead lead) async {
    final s = await pickOption<LeadStatus>(
      context,
      title: 'Change status',
      options: LeadStatus.values,
      label: (s) => s.label,
      selected: lead.status,
    );
    if (s != null && mounted) AppScope.read(context).updateLead(lead.id, (l) => l.status = s);
  }

  Future<void> _assignSheet(Lead lead) async {
    final a = await pickOption<String>(
      context,
      title: 'Assign to',
      options: agents,
      label: (a) => a,
      selected: lead.assignedTo,
    );
    if (a != null && mounted) {
      AppScope.read(context).updateLead(lead.id, (l) => l.assignedTo = a);
      showToast(context, 'Assigned to $a');
    }
  }

  Future<void> _reminderSheet(Lead lead) async {
    final options = <(String, DateTime)>[
      ('In 1 hour', DateTime.now().add(const Duration(hours: 1))),
      ('Today, 06:00 PM', _at(0, 18)),
      ('Tomorrow, 10:00 AM', _at(1, 10)),
      ('In 3 days, 11:00 AM', _at(3, 11)),
      ('Next week', _at(7, 10)),
    ];
    final picked = await pickOption<(String, DateTime)>(
      context,
      title: 'Set follow-up reminder',
      options: options,
      label: (o) => o.$1,
    );
    if (picked != null && mounted) {
      AppScope.read(context).updateLead(lead.id, (l) => l.nextFollowUp = picked.$2);
      showToast(context, 'Reminder set for ${dayAndTime(picked.$2)}');
    }
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in _tabs) ...[
          if (t != _tabs.first) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: t == value ? AppColors.primarySoft : AppColors.chip,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(t),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: t == value ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 13,
                      color: t == value ? AppColors.primary : AppColors.text,
                      fontWeight: t == value ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Small blue icon button at the end of a contact row.
class _RowAction extends StatelessWidget {
  const _RowAction(this.icon, this.onTap);
  final AppIcons icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: AppIcon(icon, size: 19, color: AppColors.primary),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, this.text = '', this.label, this.action, this.child, this.onTap});
  final AppIcons icon;
  final String text;
  final String? label;
  final Widget? action;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            AppIcon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            if (label != null)
              SizedBox(
                width: 90,
                child: Text(label!, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: child ?? Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5)),
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
