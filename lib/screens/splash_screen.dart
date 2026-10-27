import 'dart:async';

import 'package:flutter/material.dart';

import '../store/app_store.dart';
import '../widgets/logo.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
    ..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _next);
  }

  void _next() {
    _timer?.cancel();
    if (!mounted) return;
    final loggedIn = AppScope.read(context).isLoggedIn;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => loggedIn ? const MainShell() : const LoginScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: GestureDetector(
        onTap: _next,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _WavesPainter()),
            Align(
              alignment: const Alignment(0, -0.25),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _c, curve: const Interval(0, 0.35)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DovixLogo(),
                    SizedBox(height: 24),
                    Text(
                      'Smarter Conversations\nStronger Business',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _c,
                  // Two-segment indicator: blue fills the first pill, then the second.
                  builder: (_, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_pill(_c.value * 2), const SizedBox(width: 8), _pill(_c.value * 2 - 1)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pill(double progress) => Container(
    width: 44,
    height: 5,
    decoration: BoxDecoration(color: const Color(0xFFD9E2F2), borderRadius: BorderRadius.circular(3)),
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: progress.clamp(0.0, 1.0),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1F5EFF), borderRadius: BorderRadius.circular(3)),
      ),
    ),
  );
}

/// Silky flowing waves: many thin translucent curves plus a few soft bands, like the design.
class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Faint top-right swirl.
    _ribbon(
      canvas,
      size,
      y0: h * 0.12,
      amp: h * 0.06,
      count: 22,
      color: const Color(0xFF7AA2FF),
      alpha: 0.10,
      tilt: -0.15,
    );

    // Soft filled bands behind the lines.
    for (final (y, a) in [(0.66, 0.10), (0.72, 0.14), (0.80, 0.10)]) {
      final band = Path()
        ..moveTo(0, h * y)
        ..cubicTo(w * 0.35, h * (y - 0.10), w * 0.55, h * (y + 0.16), w, h * (y - 0.04))
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(band, Paint()..color = const Color(0xFF3B74FF).withValues(alpha: a));
    }

    // Main silk ribbon across the lower half.
    _ribbon(
      canvas,
      size,
      y0: h * 0.66,
      amp: h * 0.10,
      count: 46,
      color: const Color(0xFF1F5EFF),
      alpha: 0.22,
      tilt: 0.25,
    );
    _ribbon(
      canvas,
      size,
      y0: h * 0.74,
      amp: h * 0.08,
      count: 30,
      color: const Color(0xFF5B8CFF),
      alpha: 0.16,
      tilt: -0.2,
    );
  }

  void _ribbon(
    Canvas canvas,
    Size size, {
    required double y0,
    required double amp,
    required int count,
    required Color color,
    required double alpha,
    required double tilt,
  }) {
    final w = size.width;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < count; i++) {
      final t = i / count;
      final spread = (t - 0.5) * amp * 1.6;
      paint.color = color.withValues(alpha: alpha * (0.35 + 0.65 * (1 - (t - 0.5).abs() * 2)));
      final path = Path()
        ..moveTo(0, y0 + spread)
        ..cubicTo(
          w * 0.3,
          y0 - amp + spread * (1 + tilt),
          w * 0.6,
          y0 + amp + spread * (1 - tilt),
          w,
          y0 - amp * 0.3 + spread * 0.6,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
