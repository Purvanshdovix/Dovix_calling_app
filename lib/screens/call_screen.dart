import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../store/app_store.dart';
import '../theme.dart';
import '../utils/actions.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';

enum _Phase { connecting, live, ended }

const _barCount = 48;

/// Simulated ongoing call: rings briefly, then "connects" and runs a live timer.
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.leadId, required this.name, required this.phone, this.company = ''});

  final String? leadId;
  final String name;
  final String phone;
  final String company;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _rand = Random();
  _Phase _phase = _Phase.connecting;
  int _seconds = 0;
  bool _muted = false;
  late bool _speaker;
  bool _held = false;
  late bool _recording;
  bool _keypad = false;
  String _dtmf = '';
  List<double> _bars = List.filled(_barCount, 0.15);
  final _note = TextEditingController();
  Timer? _ring, _clock, _wave;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    final settings = AppScope.read(context).settings;
    _speaker = settings.speakerDefault;
    _recording = settings.autoRecord;
    _ring = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted || _phase != _Phase.connecting) return;
      setState(() => _phase = _Phase.live);
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_held) setState(() => _seconds++);
      });
      _wave = Timer.periodic(const Duration(milliseconds: 140), (_) => setState(_tickWave));
    });
  }

  void _tickWave() {
    _bars = List.generate(_barCount, (i) {
      if (_held) return 0.08;
      final center = 1 - (i - _barCount / 2).abs() / (_barCount / 2);
      return max(0.08, _rand.nextDouble() * (0.35 + center * 0.65) * (_muted ? 0.45 : 1));
    });
  }

  @override
  void dispose() {
    _ring?.cancel();
    _clock?.cancel();
    _wave?.cancel();
    _note.dispose();
    super.dispose();
  }

  void _endCall() {
    _ring?.cancel();
    _clock?.cancel();
    _wave?.cancel();
    if (!_logged) {
      _logged = true;
      AppScope.read(context).logCall(
        leadId: widget.leadId,
        name: widget.name,
        company: widget.company,
        phone: widget.phone,
        type: CallType.outgoing,
        duration: Duration(seconds: _phase == _Phase.live ? _seconds : 0),
      );
    }
    setState(() => _phase = _Phase.ended);
  }

  void _finish() {
    final text = _note.text.trim();
    if (text.isNotEmpty && widget.leadId != null) {
      AppScope.read(context).addNote(widget.leadId!, text);
      showToast(context, 'Call note saved');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final live = _phase == _Phase.live;
    final status = switch (_phase) {
      _Phase.connecting => 'Calling…',
      _Phase.ended => 'Call Ended',
      _Phase.live => _held ? 'On Hold' : 'Live Call',
    };
    final statusColor = live && !_held ? AppColors.green : (_phase == _Phase.ended ? AppColors.red : AppColors.orange);

    return PopScope(
      // Leaving mid-call ends it, so the call is always logged.
      canPop: _phase == _Phase.ended,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endCall();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEEF3FF), Colors.white, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        if (_recording && live)
                          const Text(
                            ' · REC',
                            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatDuration(Duration(seconds: _seconds)),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Faint dotted halo rings behind the avatar.
                      const SizedBox(width: 210, height: 190, child: CustomPaint(painter: _HaloPainter())),
                      Container(
                        width: 156,
                        height: 156,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFF7DB2FF), AppColors.primary]),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0EAFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Text(
                            initials(widget.name),
                            style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                      ),
                      if (live)
                        Positioned(
                          top: 22,
                          right: 34,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  if (widget.company.isNotEmpty)
                    Text(widget.company, style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
                  if (widget.phone.isNotEmpty && widget.phone != widget.name)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(widget.phone, style: const TextStyle(fontSize: 15)),
                    ),
                  const SizedBox(height: 18),
                  if (_phase == _Phase.ended) ..._summary() else ..._controls(live),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _summary() => [
    const Spacer(),
    Text(
      _seconds > 0 ? 'Talked for ${formatDuration(Duration(seconds: _seconds))}' : 'Call not connected',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMuted),
    ),
    const SizedBox(height: 14),
    if (widget.leadId != null) ...[
      TextField(
        controller: _note,
        minLines: 3,
        maxLines: 5,
        decoration: inputDecoration(hint: 'Add a quick note about this call (optional)'),
      ),
      const SizedBox(height: 14),
    ],
    SizedBox(
      width: double.infinity,
      child: AppButton('Done', onPressed: _finish),
    ),
  ];

  List<Widget> _controls(bool live) {
    final controls = <(AppIcons, String, bool, VoidCallback)>[
      (
        _muted ? AppIcons.mute : AppIcons.microphone,
        _muted ? 'Unmute' : 'Mute',
        _muted,
        () => setState(() => _muted = !_muted),
      ),
      (AppIcons.speaker, 'Speaker', _speaker, () => setState(() => _speaker = !_speaker)),
      (_held ? AppIcons.play : AppIcons.pause, _held ? 'Resume' : 'Hold', _held, () => setState(() => _held = !_held)),
      (AppIcons.keypad, 'Keypad', _keypad, () => setState(() => _keypad = true)),
      (AppIcons.addCall, 'Add Call', false, () => showToast(context, 'Conference calling needs the telephony backend')),
      (
        AppIcons.callRecord,
        _recording ? 'Recording' : 'Record',
        _recording,
        () {
          showToast(context, _recording ? 'Recording stopped' : 'Recording started');
          setState(() => _recording = !_recording);
        },
      ),
    ];

    return [
      SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _bars.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                width: 3,
                height: 6 + _bars[i] * 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  // Blue on the left fading to green on the right, as in the design.
                  color: Color.lerp(
                    AppColors.primary,
                    const Color(0xFF22C55E),
                    i / (_barCount - 1),
                  )!.withValues(alpha: live ? 1 : 0.35),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      if (_keypad) ...[
        Text(_dtmf.isEmpty ? ' ' : _dtmf, style: const TextStyle(fontSize: 24, letterSpacing: 2)),
        const SizedBox(height: 6),
        SizedBox(
          width: 260,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              for (final (k, _) in dialKeys)
                SizedBox(
                  width: 76,
                  height: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.white, shape: const StadiumBorder()),
                    onPressed: () =>
                        setState(() => _dtmf = (_dtmf + k).length > 18 ? (_dtmf + k).substring(1) : _dtmf + k),
                    child: Text(k, style: const TextStyle(fontSize: 20, color: AppColors.text)),
                  ),
                ),
            ],
          ),
        ),
        TextButton(onPressed: () => setState(() => _keypad = false), child: const Text('Hide keypad')),
      ] else
        Wrap(
          alignment: WrapAlignment.spaceAround,
          runSpacing: 16,
          children: [
            for (final (icon, label, active, onTap) in controls)
              SizedBox(
                width: 96,
                child: Opacity(
                  opacity: live ? 1 : 0.45,
                  child: InkResponse(
                    onTap: live ? onTap : null,
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: active ? AppColors.primary : const Color(0xFFDCE4F2), width: 1.2),
                          ),
                          child: AppIcon(
                            icon,
                            size: 22,
                            color: active ? Colors.white : (label.startsWith('Rec') ? AppColors.red : AppColors.navy),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(label, style: const TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      const Spacer(),
      SizedBox(
        width: 120,
        height: 60,
        child: FilledButton(
          onPressed: _endCall,
          style: FilledButton.styleFrom(backgroundColor: AppColors.red, shape: const StadiumBorder(), elevation: 6),
          child: const AppIcon(AppIcons.phoneEnd, size: 30),
        ),
      ),
    ];
  }
}

class _HaloPainter extends CustomPainter {
  const _HaloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (final (r, a) in [(88.0, 0.35), (96.0, 0.22), (104.0, 0.12)]) {
      final paint = Paint()..color = AppColors.primary.withValues(alpha: a);
      const dots = 90;
      for (var i = 0; i < dots; i++) {
        final ang = i / dots * 2 * pi;
        canvas.drawCircle(c + Offset(cos(ang) * r, sin(ang) * r), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
