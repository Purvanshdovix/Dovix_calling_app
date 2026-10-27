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

enum _Filter { all, hot, customers, unassigned }

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;
  bool _az = false; // false = original order, as in the design

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Lead l) => switch (_filter) {
    _Filter.all => true,
    _Filter.hot => l.hot,
    _Filter.customers => l.isCustomer,
    _Filter.unassigned => l.assignedTo.isEmpty,
  };

  @override
  Widget build(BuildContext context) {
    final list = AppScope.of(
      context,
    ).leads.where((l) => _matches(l) && matchesQuery([l.name, l.company, l.phone], _search.text)).toList();
    if (_az) list.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      floatingActionButton: AppFab(onPressed: () => push(context, const AddLeadScreen())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: PageHeader(
                title: 'Contacts',
                back: true,
                trailing: [
                  IconButton(
                    tooltip: _az ? 'Original order' : 'Sort A–Z',
                    icon: AppIcon(AppIcons.sort, color: _az ? AppColors.primary : AppColors.text),
                    onPressed: () => setState(() => _az = !_az),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          controller: _search,
                          hint: 'Search contacts...',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.chip,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          tooltip: 'Filter',
                          icon: AppIcon(
                            AppIcons.filter,
                            color: _filter == _Filter.all ? AppColors.text : AppColors.primary,
                          ),
                          onPressed: () async {
                            final f = await pickOption<_Filter>(
                              context,
                              title: 'Show',
                              options: _Filter.values,
                              selected: _filter,
                              label: (f) => switch (f) {
                                _Filter.all => 'All contacts',
                                _Filter.hot => 'Hot leads',
                                _Filter.customers => 'Customers',
                                _Filter.unassigned => 'Unassigned',
                              },
                            );
                            if (f != null) setState(() => _filter = f);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChips<_Filter>(
                      value: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                      items: const [
                        (_Filter.all, 'All'),
                        (_Filter.hot, 'Hot Leads'),
                        (_Filter.customers, 'Customers'),
                        (_Filter.unassigned, 'Unassigned'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(icon: AppIcons.profile, title: 'No contacts found')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final l = list[i];
                        return InkWell(
                          onTap: () => push(context, LeadDetailsScreen(leadId: l.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            // Divider starts under the name, not the avatar.
                            foregroundDecoration: const IndentedDivider(52),
                            child: Row(
                              children: [
                                Avatar(l.name),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                      Text(l.company, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const AppIcon(AppIcons.phone, color: AppColors.primary),
                                  onPressed: () => startCall(
                                    context,
                                    leadId: l.id,
                                    name: l.name,
                                    phone: l.phone,
                                    company: l.company,
                                  ),
                                ),
                                IconButton(
                                  icon: const AppIcon(AppIcons.whatsapp, color: AppColors.whatsapp),
                                  onPressed: () => openWhatsApp(context, l.phone),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
