import 'package:flutter/material.dart';

/// رسوم صفحات التعريف الثلاث — منقولة نقطة بنقطة عن إحداثيات SVG
/// بالتصميم الأصلي (لا أيقونات Material عامة)، كل رسمة على شبكتها
/// الخاصة (176 أو 200) مضروبة بـ`size.width / الشبكة`.

class SealCheckPainter extends CustomPainter {
  final Color ringColor;
  final Color checkColor;

  const SealCheckPainter({required this.ringColor, required this.checkColor});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 176;
    final center = Offset(88 * s, 88 * s);

    canvas.drawCircle(
      center,
      78 * s,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s,
    );

    _drawDashedCircle(
      canvas,
      center: center,
      radius: 64 * s,
      paint: Paint()
        ..color = ringColor.withValues(alpha: ringColor.a * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s,
      dashLength: 4 * s,
      gapLength: 7 * s,
    );

    final checkPath = Path()
      ..moveTo(56 * s, 90 * s)
      ..lineTo(78 * s, 114 * s)
      ..lineTo(124 * s, 62 * s);
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant SealCheckPainter oldDelegate) =>
      oldDelegate.ringColor != ringColor || oldDelegate.checkColor != checkColor;
}

class CalendarLockPainter extends CustomPainter {
  final Color lineColor;
  final Color accentColor;

  const CalendarLockPainter({required this.lineColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;
    Offset p(double x, double y) => Offset(x * s, y * s);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30 * s, 46 * s, 140 * s, 120 * s),
        Radius.circular(14 * s),
      ),
      linePaint,
    );

    canvas.drawLine(p(30, 78), p(170, 78), linePaint..strokeWidth = 2 * s);

    final tabPaint = Paint()..color = lineColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(60 * s, 30 * s, 8 * s, 26 * s), Radius.circular(4 * s)),
      tabPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(132 * s, 30 * s, 8 * s, 26 * s), Radius.circular(4 * s)),
      tabPaint,
    );

    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: lineColor.a * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * s;
    for (final x in [65.0, 100.0, 135.0]) {
      canvas.drawLine(p(x, 88), p(x, 166), gridPaint);
    }
    for (final y in [100.0, 122.0, 144.0]) {
      canvas.drawLine(p(30, y), p(170, y), gridPaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(118 * s, 100 * s, 35 * s, 22 * s),
        Radius.circular(6 * s),
      ),
      Paint()..color = accentColor.withValues(alpha: accentColor.a * 0.15),
    );

    final shacklePath = Path()
      ..moveTo(130 * s, 108 * s)
      ..lineTo(130 * s, 103 * s)
      ..arcToPoint(Offset(140 * s, 103 * s), radius: Radius.circular(5 * s))
      ..lineTo(140 * s, 108 * s);
    canvas.drawPath(
      shacklePath,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(127 * s, 108 * s, 16 * s, 13 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = accentColor,
    );
  }

  @override
  bool shouldRepaint(covariant CalendarLockPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.accentColor != accentColor;
}

class ReviewSparklePainter extends CustomPainter {
  final Color lineColor;
  final Color accentColor;

  const ReviewSparklePainter({required this.lineColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;
    Offset p(double x, double y) => Offset(x * s, y * s);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40 * s, 90 * s, 120 * s, 70 * s),
        Radius.circular(12 * s),
      ),
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s,
    );

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: lineColor.a * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    canvas.drawLine(p(56, 118), p(120, 118), linePaint);
    canvas.drawLine(p(56, 134), p(100, 134), linePaint);

    canvas.drawPath(
      _sparklePath(s, const [
        [100, 29], [103.9, 51.1], [126, 55],
        [103.9, 58.9], [100, 81],
        [96.1, 58.9], [74, 55],
        [96.1, 51.1], [100, 29],
      ]),
      Paint()..color = accentColor,
    );
    final outlinePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    canvas.drawPath(
      _sparklePath(s, const [
        [62, 54], [64.1, 65.9], [76, 68],
        [64.1, 70.1], [62, 82],
        [59.9, 70.1], [48, 68],
        [59.9, 65.9], [62, 54],
      ]),
      outlinePaint,
    );
    canvas.drawPath(
      _sparklePath(s, const [
        [138, 54], [140.1, 65.9], [152, 68],
        [140.1, 70.1], [138, 82],
        [135.9, 70.1], [124, 68],
        [135.9, 65.9], [138, 54],
      ]),
      outlinePaint,
    );
  }

  /// نجمة رباعية الرؤوس (Sparkle) منقولة حرفياً عن مسار الـSVG: نقطة
  /// انطلاق ثم 4 أزواج (نقطة تحكم، نقطة وصول) — [[x,y], [cx,cy,...]].
  Path _sparklePath(double s, List<List<double>> points) {
    final path = Path()..moveTo(points[0][0] * s, points[0][1] * s);
    for (var i = 1; i < points.length; i += 2) {
      path.quadraticBezierTo(
        points[i][0] * s, points[i][1] * s,
        points[i + 1][0] * s, points[i + 1][1] * s,
      );
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant ReviewSparklePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.accentColor != accentColor;
}

void _drawDashedCircle(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required Paint paint,
  required double dashLength,
  required double gapLength,
}) {
  final path = Path()
    ..addOval(Rect.fromCircle(center: center, radius: radius));
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + dashLength;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length)),
        paint,
      );
      distance = next + gapLength;
    }
  }
}
