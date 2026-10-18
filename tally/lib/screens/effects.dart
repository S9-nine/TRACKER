import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Four upright strokes and a fifth drawn across them — the Tally mark.
///
/// [progress] 0 → 1 draws the crossing stroke; the uprights are always shown.
class TallyMarkPainter extends CustomPainter {
  TallyMarkPainter({required this.progress, required this.barColor, required this.strokeColor});

  final double progress;
  final Color barColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bar = Paint()
      ..color = barColor
      ..strokeWidth = w * 0.065
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final x = w * (0.23 + i * 0.18);
      canvas.drawLine(Offset(x, h * 0.16), Offset(x, h * 0.84), bar);
    }
    if (progress <= 0) return;
    final start = Offset(w * 0.08, h * 0.72);
    final end = Offset(w * 0.92, h * 0.28);
    final stroke = Paint()
      ..color = strokeColor
      ..strokeWidth = w * 0.078
      ..strokeCap = StrokeCap.round;
    // Interpolating the endpoint (not a dash pattern) means the stroke is always drawn in full.
    canvas.drawLine(start, Offset.lerp(start, end, progress.clamp(0, 1))!, stroke);
  }

  @override
  bool shouldRepaint(TallyMarkPainter old) =>
      old.progress != progress || old.barColor != barColor || old.strokeColor != strokeColor;
}

/// The round Done control: an empty ring that, when done, fills and draws a slash.
class TallyCheck extends StatelessWidget {
  const TallyCheck({
    super.key,
    required this.done,
    required this.skipped,
    required this.color,
    required this.onColor,
    required this.idleColor,
    this.size = 30,
  });

  final bool done;
  final bool skipped;
  final Color color;
  final Color onColor;
  final Color idleColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: done ? 1 : 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, t, _) {
        final fill = t.clamp(0.0, 1.0);
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _CheckPainter(t: fill, scale: 0.85 + 0.15 * t, color: color, onColor: onColor, idle: idleColor,
                skipped: skipped),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.t,
    required this.scale,
    required this.color,
    required this.onColor,
    required this.idle,
    required this.skipped,
  });

  final double t;
  final double scale;
  final Color color;
  final Color onColor;
  final Color idle;
  final bool skipped;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1.5;
    if (skipped) {
      final p = Paint()
        ..color = idle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(c, r, p);
      canvas.drawLine(c.translate(-r * 0.45, 0), c.translate(r * 0.45, 0), p..strokeCap = StrokeCap.round);
      return;
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Color.lerp(idle, color, t)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (t <= 0) return;
    canvas.drawCircle(c, r * scale.clamp(0, 1.1) * t, Paint()..color = color);
    final a = c.translate(-r * 0.42, r * 0.28);
    final b = c.translate(r * 0.42, -r * 0.28);
    final stroke = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
    if (stroke > 0) {
      canvas.drawLine(
        a,
        Offset.lerp(a, b, stroke)!,
        Paint()
          ..color = onColor
          ..strokeWidth = size.width * 0.11
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => true;
}

/// Faint aqua embers drifting up — the Thriving "cool blue flame".
///
/// Fades in over two seconds; renders nothing when the system asks for reduced motion.
class Embers extends StatefulWidget {
  const Embers({super.key, required this.color, this.count = 10, this.opacity = 0.28});

  final Color color;
  final int count;
  final double opacity;

  @override
  State<Embers> createState() => _EmbersState();
}

class _Ember {
  _Ember(math.Random r, {bool scatter = false}) {
    reset(r, scatter: scatter);
  }

  late double x, y, speed, radius, phase, life, decay;

  void reset(math.Random r, {bool scatter = false}) {
    x = r.nextDouble();
    y = scatter ? r.nextDouble() : 1.05;
    speed = 0.0012 + r.nextDouble() * 0.0018;
    radius = 0.8 + r.nextDouble() * 1.8;
    phase = r.nextDouble() * math.pi * 2;
    life = scatter ? r.nextDouble() : 1;
    decay = 0.0025 + r.nextDouble() * 0.003;
  }
}

class _EmbersState extends State<Embers> with SingleTickerProviderStateMixin {
  final _random = math.Random();
  late final List<_Ember> _embers = List.generate(widget.count, (_) => _Ember(_random, scatter: true));
  late final AnimationController _ticker = AnimationController(vsync: this, duration: const Duration(days: 1));
  final _fadeIn = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _ticker.addListener(_step);
    _ticker.forward();
  }

  void _step() {
    for (final e in _embers) {
      e.phase += 0.04;
      e.y -= e.speed;
      e.x += math.sin(e.phase) * 0.0006;
      e.life -= e.decay;
      if (e.life <= 0 || e.y < -0.05) e.reset(_random);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _EmberPainter(
            embers: _embers,
            color: widget.color,
            opacity: () => widget.opacity * (_fadeIn.elapsedMilliseconds / 2000).clamp(0.0, 1.0),
            repaint: _ticker,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.embers, required this.color, required this.opacity, required Listenable repaint})
      : super(repaint: repaint);

  final List<_Ember> embers;
  final Color color;
  final double Function() opacity;
  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final base = opacity();
    if (base <= 0) return;
    for (final e in embers) {
      final p = Offset(e.x * size.width, e.y * size.height);
      final fade = math.min(1.0, e.life * 1.6) * math.min(1.0, (1 - e.y) * 4 + 0.2);
      final a = (base * fade).clamp(0.0, 1.0);
      // A soft halo and a bright core: two plain circles, far cheaper than a gradient per ember per frame.
      _paint.color = color.withValues(alpha: a * 0.28);
      canvas.drawCircle(p, e.radius * 3, _paint);
      _paint.color = color.withValues(alpha: a);
      canvas.drawCircle(p, e.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(_EmberPainter old) => false;
}

/// Rings rippling out from the centre plus a breathing glow — the ring screen's heartbeat.
class PulseRings extends StatefulWidget {
  const PulseRings({super.key, required this.color, this.calm = false});

  final Color color;

  /// After the task is answered the rings quieten down.
  final bool calm;

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PulsePainter(_c, widget.color, widget.calm, still),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.anim, this.color, this.calm, this.still) : super(repaint: anim);

  final Animation<double> anim;
  final Color color;
  final bool calm;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final t = still ? 0.3 : anim.value;
    final strength = calm ? 0.25 : 1.0;
    final maxR = size.shortestSide * 0.85;
    for (var i = 0; i < 4; i++) {
      final k = (t + i / 4) % 1;
      canvas.drawCircle(
        center,
        48 + k * maxR,
        Paint()
          ..color = color.withValues(alpha: (1 - k) * 0.22 * strength)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    final breathe = 0.10 + 0.04 * math.sin(t * math.pi * 2);
    canvas.drawCircle(
      center,
      maxR * 0.6,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: breathe * strength), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: maxR * 0.6)),
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.color != color || old.calm != calm;
}

/// Slide the knob across to complete. Ticks at halfway, thumps on completion.
class SlideToTally extends StatefulWidget {
  const SlideToTally({
    super.key,
    required this.onComplete,
    required this.accent,
    required this.track,
    required this.label,
    required this.labelColor,
    required this.knobIcon,
  });

  final VoidCallback onComplete;
  final Color accent;
  final Color track;
  final String label;
  final Color labelColor;
  final Color knobIcon;

  @override
  State<SlideToTally> createState() => _SlideToTallyState();
}

class _SlideToTallyState extends State<SlideToTally> with SingleTickerProviderStateMixin {
  static const _height = 68.0;
  static const _knob = 56.0;
  double _x = 0;
  bool _passedHalf = false;
  bool _done = false;
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
    ..addListener(() => setState(() => _x = _from * (1 - Curves.easeOut.transform(_back.value))));
  double _from = 0;

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final max = box.maxWidth - _knob - 12;
      final p = max <= 0 ? 0.0 : (_x / max).clamp(0.0, 1.0);
      return Container(
        height: _height,
        decoration: BoxDecoration(color: widget.track, borderRadius: BorderRadius.circular(99)),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _knob + 12 + _x,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: 1 - p,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.label,
                        style: TextStyle(color: widget.labelColor, fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Icon(Icons.keyboard_double_arrow_right, color: widget.labelColor, size: 18),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 6 + _x,
              top: 6,
              child: GestureDetector(
                onHorizontalDragUpdate: _done
                    ? null
                    : (d) {
                        _back.stop();
                        setState(() => _x = (_x + d.delta.dx).clamp(0.0, max));
                        final half = _x > max / 2;
                        if (half && !_passedHalf) HapticFeedback.selectionClick();
                        _passedHalf = half;
                      },
                onHorizontalDragEnd: _done
                    ? null
                    : (_) {
                        if (_x >= max * 0.85) {
                          setState(() {
                            _x = max;
                            _done = true;
                          });
                          HapticFeedback.heavyImpact();
                          widget.onComplete();
                        } else {
                          _from = _x;
                          _passedHalf = false;
                          _back.forward(from: 0);
                        }
                      },
                child: Container(
                  width: _knob,
                  height: _knob,
                  decoration: BoxDecoration(color: widget.accent, shape: BoxShape.circle),
                  child: CustomPaint(painter: _KnobSlash(widget.knobIcon)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _KnobSlash extends CustomPainter {
  _KnobSlash(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawLine(
      c.translate(-size.width * 0.17, size.height * 0.13),
      c.translate(size.width * 0.17, -size.height * 0.13),
      Paint()
        ..color = color
        ..strokeWidth = size.width * 0.085
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_KnobSlash old) => old.color != color;
}
