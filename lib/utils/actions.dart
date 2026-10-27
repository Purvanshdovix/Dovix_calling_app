import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/call_screen.dart';

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 2400)));
}

/// Opens the in-app ongoing-call screen (simulated; no telephony backend yet).
/// With [replace], the current route (e.g. the dialer) is swapped for the call.
void startCall(
  BuildContext context, {
  String? leadId,
  required String name,
  required String phone,
  String company = '',
  bool replace = false,
}) {
  final nav = Navigator.of(context);
  final route = PageRouteBuilder<void>(
    pageBuilder: (_, _, _) => CallScreen(leadId: leadId, name: name, phone: phone, company: company),
    transitionsBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
  replace ? nav.pushReplacement(route) : nav.push(route);
}

String _digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

Future<void> openWhatsApp(BuildContext context, String phone, {String text = ''}) async {
  final uri = Uri.parse('https://wa.me/${_digits(phone)}${text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}'}');
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
  if (!ok && context.mounted) showToast(context, 'WhatsApp is not available');
}

Future<void> openEmail(BuildContext context, String email) async {
  final ok = await launchUrl(Uri(scheme: 'mailto', path: email)).catchError((_) => false);
  if (!ok && context.mounted) showToast(context, 'No email app available');
}
