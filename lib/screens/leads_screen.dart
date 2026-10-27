import 'package:flutter/material.dart';

import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_lead_screen.dart';
import 'lead_details_screen.dart';
import '../widgets/app_icon.dart';

enum _Sort { added, recent, name, hot }

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final _search = TextEditingController();
  LeadStatus? _status; // null = All
  _Sort _sort = _Sort.added;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickSort() async {
    final s = await pickOption<_Sort>(
      context,
      title: 'Sort leads',
      options: _Sort.values,
      selected: _sort,
      label: (s) => switch (s) {
        _Sort.added => 'Default order',
        _Sort.recent => 'Most recent activity',
        _Sort.name => 'Name (A–Z)',
        _Sort.hot => 'Hot leads first',
      },
    );
    if (s != null) setState(() => _sort = s);
  }

  @override
  Widget build(BuildContext context) {
    final leads = AppScope.of(context).leads;
    final counts = <LeadStatus, int>{};
    for (final l in leads) {
      counts[l.status] = (counts[l.status] ?? 0) + 1;
    }

    DateTime activity(Lead l) => l.lastContact ?? l.createdAt;
    final list =
        leads
            .where(
              (l) =>
                  (_status == null || l.status == _status) &&
                  matchesQuery([l.name, l.company, l.phone, l.email], _search.text),
            )
            .toList()
          ..sort(switch (_sort) {
            // Store order: newest added first, seeds in their original order.
            _Sort.added => (a, b) => leads.indexOf(a).compareTo(leads.indexOf(b)),
            _Sort.name => (a, b) => a.name.compareTo(b.name),
            _Sort.hot => (a, b) => a.hot != b.hot ? (b.hot ? 1 : -1) : activity(b).compareTo(activity(a)),
            _Sort.recent => (a, b) => activity(b).compareTo(activity(a)),
          });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  PageHeader(
                    title: 'Leads (${leads.length})',
                    trailing: [
                      IconButton(
                        tooltip: 'Add lead',
                        icon: const AppIcon(AppIcons.userPlus, color: AppColors.primary),
                        onPressed: () => push(context, const AddLeadScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          controller: _search,
                          hint: 'Search leads, contacts...',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.chip,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          tooltip: 'Sort',
                          icon: AppIcon(
                            AppIcons.filter,
                            color: _sort == _Sort.added ? AppColors.text : AppColors.primary,
                          ),
                          onPressed: _pickSort,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilterChips<LeadStatus?>(
                    value: _status,
                    onChanged: (s) => setState(() => _status = s),
                    items: [
                      (null, 'All (${leads.length})'),
                      for (final s in LeadStatus.values)
                        if (counts.containsKey(s)) (s, '${s.label} (${counts[s]})'),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: AppIcons.search,
                      title: 'No leads found',
                      subtitle: 'Try a different search or filter',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _LeadRow(lead: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    const sub = TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35);
    return InkWell(
      onTap: () => push(context, LeadDetailsScreen(leadId: lead.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(lead.name, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  Text(lead.company, overflow: TextOverflow.ellipsis, style: sub),
                  Text(lead.phone, style: sub),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(top: 2), child: StatusPill(lead.status)),
            const SizedBox(width: 6),
            SizedBox(
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Call',
                    icon: const AppIcon(AppIcons.phone, size: 22, color: AppColors.green),
                    onPressed: () =>
                        startCall(context, leadId: lead.id, name: lead.name, phone: lead.phone, company: lead.company),
                  ),
                  Text(shortStamp(lead.lastContact), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
