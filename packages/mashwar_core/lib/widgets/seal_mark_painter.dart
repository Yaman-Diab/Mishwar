import 'dart:math' as math;

import 'package:flutter/material.dart';

/// يرسم رمز «الختم الموثّق» (حلقة + صح/ورقة) على شبكة 120×120 منطقية،
/// مطابقة تماماً لإحداثيات ورقة بناء الرمز بالتصميم — تُضرب كل نقطة
/// بـ`size.width / 120` لتتكيّف مع أي حجم فعلي.
///
/// نصف قطر الحلقة وسماكة الخطوط هنا هي أوزان نسخة «الختم» (2a/2b): حلقة
/// أثخن (3.4) وذراع أثخن (9.5) مقارنة بنسخة الشاشة الكريمية (2.6 / 8.5).
class SealMarkPainter extends CustomPainter {
  final bool showRing;
  final bool showMark;
  final double ringProgress;
  final Color ringColor;
  final Color markColor;
  final Color veinColor;
  final double ringStrokeWidth;
  final double armStrokeWidth;
  final double veinStrokeWidth;

  const SealMarkPainter({
    this.showRing = true,
    this.showMark = true,
    this.ringProgress = 1,
    this.ringColor = Colors.transparent,
    required this.markColor,
    required this.veinColor,
    this.ringStrokeWidth = 3.4,
    this.armStrokeWidth = 9.5,
    this.veinStrokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120;
    Offset p(double x, double y) => Offset(x * scale, y * scale);

    if (showRing && ringProgress > 0) {
      final ringPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringStrokeWidth * scale
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: p(60, 60), radius: 50 * scale);
      // يبدأ الرسم من أعلى الحلقة (12 باتجاه الساعة) مطابقةً لـ
      // rotate(-90) على دائرة الـSVG الأصلية، ويمتد باتجاه عقارب الساعة.
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * ringProgress, false, ringPaint);
    }

    if (!showMark) return;

    final armPaint = Paint()
      ..color = markColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = armStrokeWidth * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(55, 78), p(87, 42), armPaint);

    final leafPath = Path()
      ..moveTo(30 * scale, 44 * scale)
      ..cubicTo(
        49.2 * scale, 47.3 * scale,
        57.6 * scale, 58.7 * scale,
        55 * scale, 78 * scale,
      )
      ..cubicTo(
        35.8 * scale, 74.7 * scale,
        27.4 * scale, 63.3 * scale,
        30 * scale, 44 * scale,
      )
      ..close();
    canvas.drawPath(leafPath, Paint()..color = markColor);

    final veinPath = Path()
      ..moveTo(33.5 * scale, 49.5 * scale)
      ..quadraticBezierTo(41.5 * scale, 61 * scale, 52 * scale, 75 * scale);
    canvas.drawPath(
      veinPath,
      Paint()
        ..color = veinColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = veinStrokeWidth * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant SealMarkPainter oldDelegate) {
    return oldDelegate.showRing != showRing ||
        oldDelegate.showMark != showMark ||
        oldDelegate.ringProgress != ringProgress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.markColor != markColor ||
        oldDelegate.veinColor != veinColor;
  }
}
