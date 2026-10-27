import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';

enum SettingsSection {
  profile('My Profile'),
  password('Change Password'),
  notifications('Notifications'),
  calls('Call Settings'),
  app('App Settings'),
  integrations('Integrations'),
  help('Help & Support'),
  about('About');

  const SettingsSection(this.title);
  final String title;
}

/// (label, description, getter, setter) for one settings switch.
typedef _Toggle = (String, String, bool Function(AppSettings), void Function(AppSettings, bool));

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.section});
  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 32),
          children: [
            PageHeader(title: section.title, back: true),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: switch (section) {
                SettingsSection.profile => const _Profile(),
                SettingsSection.password => const _Password(),
                SettingsSection.notifications => _Toggles([
                  (
                    'Push notifications',
                    'Alerts for new leads and assignments',
                    (s) => s.pushNotifications,
                    (s, v) => s.pushNotifications = v,
                  ),
                  (
                    'Missed call alerts',
                    'Notify me when I miss a call',
                    (s) => s.missedCallAlerts,
                    (s, v) => s.missedCallAlerts = v,
                  ),
                  (
                    'Follow-up reminders',
                    'Remind me before a scheduled follow-up',
                    (s) => s.followUpReminders,
                    (s, v) => s.followUpReminders = v,
                  ),
                ]),
                SettingsSection.calls => _Toggles([
                  (
                    'Auto-record calls',
                    'Start recording when a call connects',
                    (s) => s.autoRecord,
                    (s, v) => s.autoRecord = v,
                  ),
                  (
                    'Speaker on by default',
                    'Use loudspeaker for new calls',
                    (s) => s.speakerDefault,
                    (s, v) => s.speakerDefault = v,
                  ),
                  (
                    'Auto-dial next lead',
                    'Power-dialer mode for campaigns',
                    (s) => s.autoDialNext,
                    (s, v) => s.autoDialNext = v,
                  ),
                ]),
                SettingsSection.app => _Toggles([
                  ('Dark mode', 'Coming soon', (s) => s.darkMode, (s, v) => s.darkMode = v),
                  ('Compact lists', 'Show more rows per screen', (s) => s.compactLists, (s, v) => s.compactLists = v),
                ]),
                SettingsSection.integrations => const _Integrations(),
                SettingsSection.help => const _Help(),
                SettingsSection.about => const _About(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Profile extends StatefulWidget {
  const _Profile();

  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  late final AppUser _user = AppScope.read(context).user;
  late final _name = TextEditingController(text: _user.name);
  late final _email = TextEditingController(text: _user.email);
  late final _phone = TextEditingController(text: _user.phone);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Avatar(_name.text.isEmpty ? _user.name : _name.text, size: 84, image: userPhoto)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _user.role,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(label: 'Full name', controller: _name, icon: AppIcons.profile, onChanged: (_) => setState(() {})),
        LabeledField(
          label: 'Email',
          controller: _email,
          icon: AppIcons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        LabeledField(label: 'Phone', controller: _phone, icon: AppIcons.phone, keyboardType: TextInputType.phone),
        AppButton(
          'Save Changes',
          onPressed: () {
            if (_name.text.trim().isEmpty) return showToast(context, 'Name cannot be empty');
            AppScope.read(
              context,
            ).updateUser(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim());
            showToast(context, 'Profile updated');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _Password extends StatefulWidget {
  const _Password();

  @override
  State<_Password> createState() => _PasswordState();
}

class _PasswordState extends State<_Password> {
  final _cur = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _cur.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _error = _cur.text.isEmpty
          ? 'Enter your current password'
          : _next.text.length < 8
          ? 'New password must be at least 8 characters'
          : _next.text != _confirm.text
          ? 'Passwords do not match'
          : null;
    });
    if (_error != null) return;
    showToast(context, 'Password changed');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledField(label: 'Current password', controller: _cur, obscure: true, icon: AppIcons.lock),
        LabeledField(label: 'New password', controller: _next, obscure: true, icon: AppIcons.key),
        LabeledField(label: 'Confirm new password', controller: _confirm, obscure: true, icon: AppIcons.key),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: AppColors.red)),
          ),
        AppButton('Update Password', onPressed: _save),
      ],
    );
  }
}

class _Toggles extends StatelessWidget {
  const _Toggles(this.items);
  final List<_Toggle> items;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i < items.length - 1 ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(items[i].$1, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                subtitle: Text(items[i].$2, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                value: items[i].$3(store.settings),
                onChanged: (v) => store.updateSettings((s) => items[i].$4(s, v)),
              ),
            ),
        ],
      ),
    );
  }
}

const _integrations = <(String, String, AppIcons, Color)>[
  ('WhatsApp Business', 'Send templates & chat with leads', AppIcons.whatsapp, AppColors.whatsapp),
  ('Google Sheets', 'Import leads from a spreadsheet', AppIcons.grid, AppColors.green),
  ('Facebook Lead Ads', 'Sync leads from ad forms', AppIcons.facebook, Color(0xFF1877F2)),
  ('Slack', 'Post call summaries to a channel', AppIcons.hash, Color(0xFF611F69)),
];

class _Integrations extends StatefulWidget {
  const _Integrations();

  @override
  State<_Integrations> createState() => _IntegrationsState();
}

class _IntegrationsState extends State<_Integrations> {
  final _connected = <String>{'WhatsApp Business'};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (name, desc, icon, color) in _integrations)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                IconCircle(icon, color: color, bg: AppColors.input, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                      Text(desc, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                _connected.contains(name)
                    ? TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.greenSoft,
                          foregroundColor: AppColors.green,
                        ),
                        onPressed: () => _toggle(name),
                        child: const Text('Connected'),
                      )
                    : OutlinedButton(onPressed: () => _toggle(name), child: const Text('Connect')),
              ],
            ),
          ),
      ],
    );
  }

  void _toggle(String name) {
    final on = _connected.contains(name);
    setState(() => on ? _connected.remove(name) : _connected.add(name));
    showToast(context, on ? '$name disconnected' : '$name connected');
  }
}

const _faq = [
  (
    'How do I import leads?',
    'Go to Integrations and connect Google Sheets or Facebook Lead Ads, or add leads manually with the + button.',
  ),
  (
    'Are calls recorded?',
    'Only when recording is turned on during a call, or when Auto-record is enabled in Call Settings.',
  ),
  ('How are follow-ups scheduled?', 'Open a lead and tap “Set Reminder” under Next Follow-up.'),
];

class _Help extends StatelessWidget {
  const _Help();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (q, a) in _faq)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: cardShadow,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: q == _faq.first.$1,
                title: Text(q, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(a, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5))],
              ),
            ),
          ),
        const SizedBox(height: 10),
        AppButton(
          'Contact Support',
          icon: AppIcons.headset,
          variant: ButtonVariant.outline,
          onPressed: () => showToast(context, 'Support ticket created — we’ll reach out soon'),
        ),
      ],
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          IconCircle(AppIcons.phone, color: Colors.white, bg: AppColors.primary, size: 64),
          SizedBox(height: 12),
          Text('Dovix AI Call Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Version 1.0.0 (UI preview — no backend)', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          SizedBox(height: 12),
          Text(
            'Smarter Conversations, Stronger Business.\nManage leads, calls, tasks and campaigns in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
