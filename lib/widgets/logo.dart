import 'package:flutter/material.dart';

import '../theme.dart';

/// Dovix AI logo (shared with attendance_app) with the "CALL CENTER" product line.
class DovixLogo extends StatelessWidget {
  const DovixLogo({super.key, this.scale = 1});
  final double scale;

  static const asset = 'assets/images/dovix_logo.png';

  static Widget _rule(double scale, List<Color> colors) => Container(
    width: 44 * scale,
    height: 2,
    decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 230 * scale, height: 230 * scale, fit: BoxFit.contain),
        Transform.translate(
          offset: Offset(0, -8 * scale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _rule(scale, const [Color(0x001F5EFF), Color(0xFF8DB0FF)]),
              SizedBox(width: 10 * scale),
              Text(
                'CALL CENTER',
                style: TextStyle(
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: AppColors.text,
                ),
              ),
              SizedBox(width: 10 * scale),
              _rule(scale, const [Color(0xFF8EE3A6), Color(0x0022C55E)]),
            ],
          ),
        ),
      ],
    );
  }
}
