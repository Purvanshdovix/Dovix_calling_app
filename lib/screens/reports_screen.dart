import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';

final _totalSources = leadSourceBreakdown.fold<int>(0, (a, s) => a + s.$2);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'This Month';

  @override
  Widget build(BuildContext context) {
    final r = reportPeriods[_period]!;
    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 32),
          children: [
            PageHeader(
              title: 'Reports',
              back: true,
              trailing: [
                PillSelect(
                  value: _period,
                  options: reportPeriods.keys.toList(),
                  onChanged: (p) => setState(() => _period = p),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  row(
                    _Kpi(
                      AppIcons.barChart,
                      AppColors.primary,
                      AppColors.primarySoft,
                      'Total Calls',
                      formatNumber(r.totalCalls),
                      r.callsDelta,
                    ),
                    _Kpi(
                      AppIcons.phone,
                      AppColors.green,
                      AppColors.greenSoft,
                      'Connected',
                      formatNumber(r.connected),
                      r.connectedDelta,
                    ),
                  ),
                  const SizedBox(height: 12),
                  row(
                    _Kpi(
                      AppIcons.pieChart,
                      AppColors.purple,
                      AppColors.purpleSoft,
                      'Conversion',
                      '${r.conversion}%',
                      r.conversionDelta,
                    ),
                    _Kpi(
                      AppIcons.clock,
                      AppColors.orange,
                      AppColors.orangeSoft,
                      'Avg. Talk Time',
                      formatTalk(r.avgTalkSecs),
                      r.avgTalkDelta,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Call Performance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        SizedBox(
                          width: double.infinity,
                          height: 170,
                          child: CustomPaint(painter: _LineChartPainter(r.trendLabels, r.trendValues)),
                        ),
                      ],
                    ),
                  ),
                  const SectionTitle('Lead Sources'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 136,
                          height: 136,
                          child: CustomPaint(
                            painter: _DonutPainter(),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatNumber(_totalSources),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                  ),
                                  const Text('Total Leads', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              for (final (label, value, color) in leadSourceBreakdown)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Color(color),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          label,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      Text(
                                        formatNumber(value),
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: 34,
                                        child: Text(
                                          '${(value / _totalSources * 100).round()}%',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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

class _Kpi extends StatelessWidget {
  const _Kpi(this.icon, this.tint, this.bg, this.label, this.value, this.delta);
  final AppIcons icon;
  final Color tint;
  final Color bg;
  final String label;
  final String value;
  final double delta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconTile(icon, color: tint, bg: bg, size: 46),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                ),
                Delta(delta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _text(Canvas canvas, String s, Offset at, TextStyle style, {TextAlign align = TextAlign.center}) {
  final tp = TextPainter(
    text: TextSpan(text: s, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final dx = switch (align) {
    TextAlign.right => at.dx - tp.width,
    TextAlign.left => at.dx,
    _ => at.dx - tp.width / 2,
  };
  tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.labels, this.values);
  final List<String> labels;
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0, r = 12.0, t = 34.0, b = 24.0;
    final w = size.width - l - r, h = size.height - t - b;
    final maxV = values.reduce(max) * 1.15;
    final big = maxV > 5000;
    const axis = TextStyle(fontSize: 9, color: AppColors.textLight);

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final f in [0.0, 0.5, 1.0]) {
      final y = t + h * (1 - f);
      for (var x = l; x < size.width - r; x += 7) {
        canvas.drawLine(Offset(x, y), Offset(min(x + 3, size.width - r), y), grid);
      }
      final v = maxV * f;
      _text(canvas, big ? '${(v / 1000).round()}k' : '${v.round()}', Offset(l - 6, y), axis, align: TextAlign.right);
    }

    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(l + (values.length == 1 ? w / 2 : i / (values.length - 1) * w), t + h - values[i] / maxV * h),
    ];
    // Smooth monotone-ish curve through the points (midpoint cubic segments).
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1], p1 = pts[i];
      final mx = (p0.dx + p1.dx) / 2;
      line.cubicTo(mx, p0.dy, mx, p1.dy, p1.dx, p1.dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, t + h)
      ..lineTo(pts.first.dx, t + h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, t, size.width, h)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );
    for (final p in pts) {
      canvas.drawCircle(p, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.2, Paint()..color = AppColors.primary);
    }
    for (var i = 0; i < labels.length; i++) {
      _text(
        canvas,
        labels[i],
        Offset(pts[i].dx, size.height - 8),
        const TextStyle(fontSize: 10, color: AppColors.textMuted),
      );
    }

    // Tooltip on the latest point.
    final tip = '${formatNumber(values.last)} calls';
    final tp = TextPainter(
      text: TextSpan(
        text: tip,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final boxW = tp.width + 16;
    final left = min(pts.last.dx - boxW / 2, size.width - boxW - 2);
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(left, pts.last.dy - 30, boxW, 22), const Radius.circular(6));
    canvas.drawRRect(rect, Paint()..color = AppColors.text);
    tp.paint(canvas, Offset(left + 8, pts.last.dy - 30 + (22 - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.values != values;
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 24.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: (size.shortestSide - stroke) / 2);
    var start = -pi / 2;
    for (final (_, value, color) in leadSourceBreakdown) {
      final sweep = value / _totalSources * 2 * pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = Color(color),
      );
      // White gap between segments, as in the design.
      final c = rect.center, rIn = rect.width / 2 - stroke / 2, rOut = rect.width / 2 + stroke / 2;
      canvas.drawLine(
        c + Offset(cos(start) * rIn, sin(start) * rIn),
        c + Offset(cos(start) * rOut, sin(start) * rOut),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
