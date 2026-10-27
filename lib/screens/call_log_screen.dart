import 'package:flutter/material.dart';

import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'lead_details_screen.dart';
import '../widgets/app_icon.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  CallType? _filter; // null = All
  bool _searching = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calls = AppScope.of(context).calls;
    final sorted =
        calls
            .where(
              (c) => (_filter == null || c.type == _filter) && matchesQuery([c.name, c.company, c.phone], _search.text),
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final groups = <String, List<CallLog>>{};
    for (final c in sorted) {
      groups.putIfAbsent(dayLabel(c.timestamp), () => []).add(c);
    }
    final missed = calls.where((c) => c.type == CallType.missed).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Column(
                children: [
                  PageHeader(
                    title: 'Call Log',
                    back: true,
                    trailing: [
                      IconButton(
                        icon: AppIcon(_searching ? AppIcons.close : AppIcons.search),
                        onPressed: () => setState(() {
                          _searching = !_searching;
                          _search.clear();
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      children: [
                        if (_searching) ...[
                          SearchField(
                            controller: _search,
                            hint: 'Search name or number',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilterChips<CallType?>(
                            value: _filter,
                            onChanged: (f) => setState(() => _filter = f),
                            items: [
                              (null, 'All'),
                              (CallType.incoming, 'Incoming'),
                              (CallType.outgoing, 'Outgoing'),
                              (CallType.missed, missed > 0 ? 'Missed ($missed)' : 'Missed'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: groups.isEmpty
                  ? const EmptyState(icon: AppIcons.phone, title: 'No calls here')
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      children: [
                        for (final MapEntry(key: day, value: list) in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 18, bottom: 6),
                            child: Text(day, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          for (final c in list) _CallRow(call: c),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.call});
  final CallLog call;

  @override
  Widget build(BuildContext context) {
    final missed = call.type == CallType.missed;
    void callBack() =>
        startCall(context, leadId: call.leadId, name: call.name, phone: call.phone, company: call.company);

    return InkWell(
      onTap: () => call.leadId != null ? push(context, LeadDetailsScreen(leadId: call.leadId!)) : callBack(),
      // The design has no call-back button on the row; long-press redials.
      onLongPress: callBack,
      child: Container(
        foregroundDecoration: const IndentedDivider(60),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            IconTile(
              AppIcons.wifiCall,
              color: missed ? AppColors.red : AppColors.green,
              bg: missed ? AppColors.redSoft : AppColors.greenSoft,
              size: 46,
              iconSize: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(call.name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                  Text(
                    call.company.isEmpty ? call.phone : call.company,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatTime(call.timestamp), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(
                  missed ? 'Missed' : formatDuration(call.duration),
                  style: TextStyle(fontSize: 12, color: missed ? AppColors.red : AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
