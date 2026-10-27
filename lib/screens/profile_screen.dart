import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import '../widgets/app_icon.dart';

const _settings = <(AppIcons, String, SettingsSection)>[
  (AppIcons.profile, 'My Profile', SettingsSection.profile),
  (AppIcons.lock, 'Change Password', SettingsSection.password),
  (AppIcons.notifications, 'Notifications', SettingsSection.notifications),
  (AppIcons.phone, 'Call Settings', SettingsSection.calls),
  (AppIcons.settings, 'App Settings', SettingsSection.app),
  (AppIcons.integrations, 'Integrations', SettingsSection.integrations),
  (AppIcons.help, 'Help & Support', SettingsSection.help),
  (AppIcons.info, 'About', SettingsSection.about),
];

/// "More" tab — Profile & Settings from the design, plus links to the other workspace screens.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const PageHeader(title: 'Profile & Settings'),
          const SizedBox(height: 8),
          AppCard(
            onTap: () => push(context, const SettingsScreen(section: SettingsSection.profile)),
            child: Row(
              children: [
                Stack(
                  children: [
                    Avatar(user.name, size: 68, image: userPhoto),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(user.role, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      Text(user.email, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _menu([
            for (final (icon, label, section) in _settings)
              (icon, label, () => push(context, SettingsScreen(section: section))),
          ]),
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.redSoft,
                foregroundColor: AppColors.red,
                side: const BorderSide(color: Color(0xFFFBCACA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const AppIcon(AppIcons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              onPressed: () {
                AppScope.read(context).logout();
                Navigator.of(
                  context,
                ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              },
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Dovix AI Call Center · v1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _menu(List<(AppIcons, String, VoidCallback)> items) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: items[i].$3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                foregroundDecoration: i < items.length - 1 ? const IndentedDivider(36) : null,
                child: Row(
                  children: [
                    AppIcon(items[i].$1, size: 21, color: AppColors.navy),
                    const SizedBox(width: 14),
                    Expanded(child: Text(items[i].$2, style: const TextStyle(fontSize: 14.5))),
                    const AppIcon(AppIcons.chevronRight, size: 20, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
