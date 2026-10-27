import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../widgets/common.dart';
import '../widgets/logo.dart';
import 'main_shell.dart';
import '../widgets/app_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _password = TextEditingController();
  bool _showPw = false;
  bool _remember = true;
  bool _loading = false;
  String? _idError;
  String? _pwError;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  Future<void> _submit() async {
    final id = _id.text.trim();
    final isEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(id);
    final isPhone = RegExp(r'^\+?\d{10,13}$').hasMatch(id.replaceAll(RegExp(r'[\s-]'), ''));
    setState(() {
      _idError = id.isEmpty
          ? 'Enter your email or mobile number'
          : (!isEmail && !isPhone ? 'Enter a valid email or 10-digit mobile number' : null);
      _pwError = _password.text.isEmpty
          ? 'Enter your password'
          : (_password.text.length < 4 ? 'Password must be at least 4 characters' : null);
    });
    if (_idError != null || _pwError != null) return;

    // No backend yet: any well-formed credentials sign in.
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    AppScope.read(context).login(id);
    _goHome();
  }

  void _sso(String provider) {
    AppScope.read(context).login('');
    showToast(context, 'Signed in with $provider');
    _goHome();
  }

  void _forgot() {
    final ctrl = TextEditingController(text: _id.text);
    showAppSheet<void>(
      context,
      title: 'Reset password',
      children: (ctx) => [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            "We'll send a reset link to your registered email or mobile.",
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        LabeledField(controller: ctrl, hint: 'Email or Mobile Number', icon: AppIcons.email),
        AppButton(
          'Send reset link',
          onPressed: () {
            Navigator.pop(ctx);
            showToast(context, ctrl.text.trim().isEmpty ? 'Reset link sent' : 'Reset link sent to ${ctrl.text.trim()}');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DovixLogo(scale: 0.68),
            const SizedBox(height: 14),
            const Text('Welcome Back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Sign in to your account to manage leads, calls and campaigns.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 22),
            LabeledField(
              controller: _id,
              hint: 'Email or Mobile Number',
              icon: AppIcons.email,
              keyboardType: TextInputType.emailAddress,
              error: _idError,
            ),
            LabeledField(
              controller: _password,
              hint: 'Password',
              icon: AppIcons.lock,
              obscure: !_showPw,
              error: _pwError,
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                icon: AppIcon(_showPw ? AppIcons.eyeOff : AppIcons.eye, color: AppColors.textMuted, size: 20),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
            Row(
              children: [
                CheckBox(checked: _remember, onTap: () => setState(() => _remember = !_remember)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Remember me',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
                GestureDetector(
                  onTap: _forgot,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _GradientButton(label: _loading ? 'Signing in…' : 'Login', onPressed: _loading ? null : _submit),
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _SsoButton(label: 'Google', mark: const _GoogleMark(), onTap: () => _sso('Google')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SsoButton(label: 'Microsoft', mark: const _MicrosoftMark(), onTap: () => _sso('Microsoft')),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => showToast(context, 'Request sent to your admin'),
                    child: const Text(
                      'Contact Admin',
                      style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
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

/// Full-width blue gradient button with the label centred and an arrow at the right edge.
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.7 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0xFF2B6BFF), Color(0xFF1450F0)]),
          boxShadow: const [BoxShadow(color: Color(0x401F5EFF), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Positioned(right: 20, child: AppIcon(AppIcons.arrowRight, size: 20, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  const _SsoButton({required this.label, required this.mark, required this.onTap});
  final String label;
  final Widget mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mark,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four-colour Google "G".
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size.square(20), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: (size.width - w) / 2);
    Paint p(int c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = Color(c);
    double rad(double deg) => deg * math.pi / 180;
    canvas.drawArc(rect, rad(-15), rad(60), false, p(0xFF4285F4)); // blue, right
    canvas.drawArc(rect, rad(45), rad(90), false, p(0xFF34A853)); // green, bottom
    canvas.drawArc(rect, rad(135), rad(80), false, p(0xFFFBBC05)); // yellow, left
    canvas.drawArc(rect, rad(215), rad(100), false, p(0xFFEA4335)); // red, top
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(size.width / 2, size.height / 2 - w / 2, size.width / 2 - w / 4, w), bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Four-square Microsoft logo.
class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark();

  @override
  Widget build(BuildContext context) {
    Widget sq(int c) => Container(width: 9, height: 9, color: Color(c));
    return SizedBox(
      width: 20,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(0xFFF25022), sq(0xFF7FBA00)]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(0xFF00A4EF), sq(0xFFFFB900)]),
        ],
      ),
    );
  }
}
