import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/actions.dart';
import 'dialer_screen.dart';
import 'home_screen.dart';
import 'leads_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import '../widgets/app_icon.dart';

/// Bottom navigation (Home, Leads, [Call], Tasks, More) from the design.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Lets nested screens switch tabs (e.g. dashboard cards → Leads).
  static void goToTab(BuildContext context, int index) =>
      context.findAncestorStateOfType<_MainShellState>()?._select(index);

  static const home = 0, leads = 1, tasks = 2, more = 3;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  static const _pages = [HomeScreen(), LeadsScreen(), TasksScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 62,
        height: 62,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: raisedShadow),
        padding: const EdgeInsets.all(4),
        child: FloatingActionButton(
          heroTag: 'dial',
          elevation: 0,
          tooltip: 'Open dialer',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () => push(context, const DialerScreen()),
          child: const AppIcon(AppIcons.phone, size: 26),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        height: 66,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: [
            _item(0, AppIcons.home, 'Home'),
            _item(1, AppIcons.users, 'Leads'),
            const Expanded(child: SizedBox()),
            _item(2, AppIcons.checklist, 'Tasks'),
            _item(3, AppIcons.menu, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _item(int i, AppIcons icon, String label) {
    final selected = _index == i;
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: InkResponse(
        onTap: () => _select(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
