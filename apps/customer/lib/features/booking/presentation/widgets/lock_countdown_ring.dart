import 'dart:math' as math;

import 'package:flutter/material.dart';

class LockCountdownRing extends StatelessWidget {
  static const totalDuration = Duration(minutes: 10);

  final Duration remaining;
  final double size;
  final Color trackColor;
  final Color progressColor;
  final Widget center;

  const LockCountdownRing({
    super.key,
    required this.remaining,
    required this.size,
    required this.trackColor,
    required this.progressColor,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    final fraction =
        (remaining.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              fraction: fraction,
              trackColor: trackColor,
              progressColor: progressColor,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color progressColor;

  const _RingPainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.042;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
