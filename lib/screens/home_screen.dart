import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'call_log_screen.dart';
import 'campaigns_screen.dart';
import 'contacts_screen.dart';
import 'main_shell.dart';
import 'reports_screen.dart';
import '../widgets/app_icon.dart';

/// Series in data order [connected, notAnswered, busy]; bars stack green, blue, then slate on top as in the design.
const _series = [('Connected', Color(0xFF22C55E)), ('Not Answered', Color(0xFFC3CEE3)), ('Busy', Color(0xFF2F6BFF))];
const _stackOrder = [0, 2, 1];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _period = 'Today';

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    // Mock analytics baseline plus whatever was added during this session.
    final totalLeads = 12480 - store.baselineLeadCount + store.leads.length;
    final callsToday = 1284 + store.calls.length - store.baselineCallCount;
    final pending = store.tasks.where((t) => !t.done).length;
    final (labels, data) = hourlyActivity[_period]!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => MainShell.goToTab(context, MainShell.more),
                child: Avatar(store.user.name, size: 52, image: userPhoto),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${greeting()} 👋', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    Text(store.user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(fullDate(DateTime.now()), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              InkResponse(
                onTap: () => MainShell.goToTab(context, MainShell.tasks),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: Badge(
                    isLabelVisible: pending > 0,
                    label: Text('$pending'),
                    offset: const Offset(-4, 6),
                    alignment: Alignment.topRight,
                    child: const Center(child: AppIcon(AppIcons.notifications, color: AppColors.primary)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _grid([
            _Stat(
              AppIcons.users,
              AppColors.primary,
              AppColors.primarySoft,
              'Total Leads',
              formatNumber(totalLeads),
              18.6,
              'vs last month',
              () => MainShell.goToTab(context, MainShell.leads),
            ),
            _Stat(
              AppIcons.phone,
              AppColors.green,
              AppColors.greenSoft,
              'Calls Today',
              formatNumber(callsToday),
              12.4,
              'vs yesterday',
              () => push(context, const CallLogScreen()),
            ),
            _Stat(
              AppIcons.wifiCall,
              AppColors.purple,
              AppColors.purpleSoft,
              'Connected Calls',
              '892',
              8.2,
              '69.5% connect rate',
              () => push(context, const ReportsScreen()),
            ),
            _Stat(
              AppIcons.followup,
              AppColors.orange,
              AppColors.orangeSoft,
              'Follow-ups Due',
              '${80 + pending}',
              -12.6,
              'Pending follow-ups',
              () => MainShell.goToTab(context, MainShell.tasks),
            ),
          ]),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${_period == 'Today' ? "Today's" : "This Week's"} Call Activity",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    PillSelect(
                      value: _period,
                      options: hourlyActivity.keys.toList(),
                      onChanged: (p) => setState(() => _period = p),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StackedBars(labels: labels, data: data),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < _series.length; i++)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: _series[i].$2),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _series[i].$1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14, top: 4),
                              child: Text(
                                formatNumber(data.fold<int>(0, (a, r) => a + r[i])),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SectionTitle('Quick Access'),
          Row(
            children: [
              _quick(AppIcons.phone, 'Call Logs', AppColors.green, const CallLogScreen()),
              const SizedBox(width: 10),
              _quick(AppIcons.profile, 'Contacts', AppColors.primary, const ContactsScreen()),
              const SizedBox(width: 10),
              _quick(AppIcons.megaphone, 'Campaigns', AppColors.purple, const CampaignsScreen()),
              const SizedBox(width: 10),
              _quick(AppIcons.barChart, 'Reports', AppColors.orange, const ReportsScreen()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grid(List<_Stat> stats) {
    return Column(
      children: [
        for (var r = 0; r < stats.length; r += 2) ...[
          if (r > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: stats[r]),
                const SizedBox(width: 12),
                Expanded(child: stats[r + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _quick(AppIcons icon, String label, Color color, Widget page) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        onTap: () => push(context, page),
        child: Column(
          children: [
            AppIcon(icon, color: color),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.tint, this.bg, this.label, this.value, this.delta, this.foot, this.onTap);
  final AppIcons icon;
  final Color tint;
  final Color bg;
  final String label;
  final String value;
  final double delta;
  final String foot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon, color: tint, bg: bg, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 4),
                Delta(delta),
                const SizedBox(height: 2),
                Text(
                  foot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedBars extends StatelessWidget {
  const _StackedBars({required this.labels, required this.data});
  final List<String> labels;
  final List<List<int>> data;

  @override
  Widget build(BuildContext context) {
    const h = 120.0;
    final max = data.map((r) => r.fold<int>(0, (a, b) => a + b)).reduce((a, b) => a > b ? a : b);
    const axis = TextStyle(fontSize: 9.5, color: AppColors.textMuted);
    final ticks = [1.0, 0.66, 0.33, 0.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [for (final f in ticks) Text('${(max * f).round()}', style: axis)],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: h,
                child: Stack(
                  children: [
                    // Light horizontal grid.
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [for (final _ in ticks) const Divider(height: 1, color: Color(0xFFEFF2F8))],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final row in data)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                              bottom: Radius.circular(2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final j in _stackOrder.reversed)
                                  Container(width: 20, height: row[j] / max * h, color: _series[j].$2),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final l in labels)
                    SizedBox(
                      width: 34,
                      child: Text(l, textAlign: TextAlign.center, style: axis),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
