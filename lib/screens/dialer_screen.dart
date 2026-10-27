import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_lead_screen.dart';
import '../widgets/app_icon.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _num = '';

  String get _digits => _num.replaceAll(RegExp(r'\D'), '');

  void _callLead(Lead l) {
    startCall(context, leadId: l.id, name: l.name, phone: l.phone, company: l.company, replace: true);
  }

  void _dial(List<Lead> leads) {
    if (_digits.length < 3) {
      showToast(context, 'Enter a number to call');
      return;
    }
    final match = leads.where((l) => l.phone.replaceAll(RegExp(r'\D'), '').endsWith(_digits)).firstOrNull;
    if (match != null) {
      _callLead(match);
    } else {
      startCall(context, name: _num, phone: _num, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leads = AppScope.of(context).leads;
    final suggestions = _num.length >= 3
        ? leads.where((l) => matchesQuery([l.phone], _num)).take(3).toList()
        : <Lead>[];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Column(
            children: [
              const PageHeader(title: 'Dialer', back: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (final l in suggestions)
                        AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          onTap: () => _callLead(l),
                          child: Row(
                            children: [
                              Avatar(l.name, size: 36),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(l.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              const AppIcon(AppIcons.phone, size: 18, color: AppColors.green),
                            ],
                          ),
                        ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_num.isEmpty ? ' ' : _num, style: const TextStyle(fontSize: 34, letterSpacing: 1)),
                      ),
                      if (_num.isNotEmpty)
                        TextButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushReplacement(MaterialPageRoute(builder: (_) => AddLeadScreen(phone: _num))),
                          child: const Text('+ Add as new lead', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.45,
                  children: [
                    for (final (k, sub) in dialKeys)
                      Material(
                        color: Colors.white,
                        shape: const StadiumBorder(),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => setState(() => _num = _num.length < 15 ? _num + k : _num),
                          onLongPress: k == '0' ? () => setState(() => _num += '+') : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(k, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                              if (sub.isNotEmpty)
                                Text(
                                  sub,
                                  style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, letterSpacing: 1.5),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 64),
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: FloatingActionButton(
                      heroTag: 'dialer-call',
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: () => _dial(leads),
                      child: const AppIcon(AppIcons.phone, size: 28),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: _num.isEmpty
                        ? null
                        : GestureDetector(
                            onLongPress: () => setState(() => _num = ''),
                            child: IconButton(
                              icon: const AppIcon(AppIcons.backspace, color: AppColors.textMuted),
                              onPressed: () => setState(() => _num = _num.substring(0, _num.length - 1)),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
