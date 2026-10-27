import 'package:flutter/material.dart';

import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';

(Color fg, Color bg) _statusColors(CampaignStatus s) => switch (s) {
  CampaignStatus.active => (AppColors.green, AppColors.greenSoft),
  CampaignStatus.scheduled => (AppColors.primary, AppColors.primarySoft),
  CampaignStatus.paused => (AppColors.orange, AppColors.orangeSoft),
  CampaignStatus.completed => (AppColors.textMuted, AppColors.input),
};

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final _search = TextEditingController();
  CampaignStatus? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _create() {
    final name = TextEditingController();
    final target = TextEditingController();
    var startAs = CampaignStatus.active;
    String? error;
    showAppSheet<void>(
      context,
      title: 'Create campaign',
      children: (ctx) => [
        StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(label: 'Campaign name', required: true, controller: name, hint: 'e.g. Diwali Offer'),
              LabeledField(
                label: 'Target calls',
                required: true,
                controller: target,
                hint: 'e.g. 1000',
                keyboardType: TextInputType.number,
              ),
              SelectField<CampaignStatus>(
                label: 'Start as',
                value: startAs,
                options: const [CampaignStatus.active, CampaignStatus.scheduled],
                optionLabel: (s) => s.label,
                onChanged: (s) => setSheet(() => startAs = s),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(error!, style: const TextStyle(color: AppColors.red)),
                ),
              AppButton(
                'Create Campaign',
                onPressed: () {
                  final total = int.tryParse(target.text.trim()) ?? 0;
                  if (name.text.trim().isEmpty) return setSheet(() => error = 'Give the campaign a name');
                  if (total < 1) return setSheet(() => error = 'Enter the number of calls to make');
                  AppScope.read(context).addCampaign(name.text.trim(), total, startAs);
                  Navigator.pop(ctx);
                  showToast(context, 'Campaign “${name.text.trim()}” created');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _actions(Campaign c) {
    final store = AppScope.read(context);
    void set(BuildContext ctx, CampaignStatus s) {
      store.setCampaignStatus(c.id, s);
      Navigator.pop(ctx);
      showToast(context, '${c.name} is now ${s.label.toLowerCase()}');
    }

    showAppSheet<void>(
      context,
      title: c.name,
      children: (ctx) => [
        if (c.status == CampaignStatus.scheduled || c.status == CampaignStatus.paused)
          SheetOption(
            icon: AppIcons.play,
            label: c.status == CampaignStatus.scheduled ? 'Start now' : 'Resume',
            onTap: () => set(ctx, CampaignStatus.active),
          ),
        if (c.status == CampaignStatus.active)
          SheetOption(icon: AppIcons.pause, label: 'Pause campaign', onTap: () => set(ctx, CampaignStatus.paused)),
        if (c.status != CampaignStatus.completed)
          SheetOption(icon: AppIcons.check, label: 'Mark as completed', onTap: () => set(ctx, CampaignStatus.completed))
        else
          SheetOption(icon: AppIcons.refresh, label: 'Restart campaign', onTap: () => set(ctx, CampaignStatus.active)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = AppScope.of(
      context,
    ).campaigns.where((c) => (_filter == null || c.status == _filter) && matchesQuery([c.name], _search.text)).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 32),
          children: [
            PageHeader(
              title: 'Campaigns',
              back: true,
              trailing: [
                FilledButton.icon(
                  onPressed: _create,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const AppIcon(AppIcons.add, size: 18),
                  label: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchField(controller: _search, hint: 'Search campaigns...', onChanged: (_) => setState(() {})),
                  const SizedBox(height: 12),
                  FilterChips<CampaignStatus?>(
                    value: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    // Design shows All / Active / Scheduled / Completed; paused ones appear under All.
                    items: [
                      (null, 'All'),
                      for (final s in [CampaignStatus.active, CampaignStatus.scheduled, CampaignStatus.completed])
                        (s, s.label),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (list.isEmpty) const EmptyState(icon: AppIcons.megaphone, title: 'No campaigns'),
                  if (list.isNotEmpty)
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Column(
                        children: [
                          for (final c in list) _CampaignCard(c, last: c == list.last, onTap: () => _actions(c)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard(this.c, {required this.onTap, required this.last});
  final Campaign c;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pct = c.total == 0 ? 0.0 : c.done / c.total;
    final color = Color(c.color);
    final (fg, bg) = _statusColors(c.status);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundDecoration: last ? null : const IndentedDivider(58),
        child: Column(
          children: [
            Row(
              children: [
                IconTile(
                  campaignIcons[c.iconCode % campaignIcons.length],
                  color: color,
                  bg: color.withValues(alpha: 0.12),
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(
                        '${formatNumber(c.done)} / ${formatNumber(c.total)} calls',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Pill(c.status.label, fg: fg, bg: bg),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 58, right: 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppProgressBar(
                      pct,
                      color: c.status == CampaignStatus.paused ? AppColors.orange : AppColors.green,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(pct * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
