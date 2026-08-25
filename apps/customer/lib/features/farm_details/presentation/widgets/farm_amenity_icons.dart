import 'package:flutter/material.dart';

/// أنواع المرافق المدعومة — كل نوع له رمز خطي مرسوم يدوياً (منقول عن
/// مسارات SVG بالتصميم الأصلي) بدل أيقونات Material العامة، حفاظاً على
/// اتساق لغة الخطوط البصرية مع بقية أيقونات العلامة (الختم، رسوم
/// التعريف).
enum AmenityType { pool, bbq, kitchen, heating, ac, playground, bedrooms, bathrooms }

class AmenityIconPainter extends CustomPainter {
  final AmenityType type;
  final Color color;

  const AmenityIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 28;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (type) {
      case AmenityType.pool:
        final waves = Path()
          ..moveTo(3 * s, 19.5 * s)
          ..cubicTo(4.8 * s, 17.9 * s, 6.6 * s, 17.9 * s, 8.5 * s, 19.5 * s)
          ..cubicTo(10.3 * s, 21.1 * s, 12.1 * s, 21.1 * s, 14 * s, 19.5 * s)
          ..cubicTo(15.8 * s, 17.9 * s, 17.6 * s, 17.9 * s, 19.5 * s, 19.5 * s)
          ..cubicTo(21.3 * s, 21.1 * s, 23.1 * s, 21.1 * s, 25 * s, 19.5 * s);
        canvas.drawPath(waves, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(9 * s, 16 * s)
            ..lineTo(9 * s, 6.5 * s)
            ..arcToPoint(p(14, 6.5), radius: Radius.circular(2.5 * s)),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(18 * s, 16 * s)
            ..lineTo(18 * s, 6.5 * s)
            ..arcToPoint(p(23, 6.5), radius: Radius.circular(2.5 * s)),
          stroke,
        );
        canvas.drawLine(p(9, 11), p(14, 11), stroke);
        canvas.drawLine(p(18, 11), p(23, 11), stroke);

      case AmenityType.bbq:
        canvas.drawPath(
          Path()
            ..moveTo(6 * s, 11 * s)
            ..lineTo(22 * s, 11 * s)
            ..lineTo(19.6 * s, 19.5 * s)
            ..cubicTo(19.4 * s, 20.4 * s, 18.6 * s, 21 * s, 17.7 * s, 21 * s)
            ..lineTo(10.3 * s, 21 * s)
            ..cubicTo(9.4 * s, 21 * s, 8.6 * s, 20.4 * s, 8.4 * s, 19.5 * s)
            ..close(),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(11 * s, 8 * s)
            ..cubicTo(11 * s, 6.4 * s, 12.2 * s, 6 * s, 12.2 * s, 4.5 * s),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(15.4 * s, 8 * s)
            ..cubicTo(15.4 * s, 6.4 * s, 16.6 * s, 6 * s, 16.6 * s, 4.5 * s),
          stroke,
        );
        canvas.drawLine(p(10, 21.5), p(8.6, 25), stroke);
        canvas.drawLine(p(18, 21.5), p(19.4, 25), stroke);

      case AmenityType.kitchen:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(5 * s, 4.5 * s, 18 * s, 19 * s),
            Radius.circular(2.6 * s),
          ),
          stroke,
        );
        canvas.drawLine(p(5, 11.5), p(23, 11.5), stroke);
        canvas.drawLine(p(9, 7.8), p(12, 7.8), stroke);
        canvas.drawLine(p(9, 16), p(13, 16), stroke);

      case AmenityType.heating:
        canvas.drawPath(
          Path()
            ..moveTo(10 * s, 24 * s)
            ..cubicTo(8.4 * s, 21.6 * s, 9 * s, 19.6 * s, 10.6 * s, 17.6 * s)
            ..cubicTo(12.3 * s, 15.6 * s, 12.6 * s, 14 * s, 11.7 * s, 12 * s)
            ..cubicTo(14.7 * s, 12.8 * s, 16.3 * s, 15 * s, 16.3 * s, 17.4 * s)
            ..cubicTo(16.3 * s, 18.3 * s, 16 * s, 19.1 * s, 15.7 * s, 19.7 * s)
            ..cubicTo(16.9 * s, 19.2 * s, 17.7 * s, 18.1 * s, 18 * s, 16.7 * s)
            ..cubicTo(19.4 * s, 19.1 * s, 19 * s, 21.8 * s, 17 * s, 24 * s),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(12.3 * s, 12 * s)
            ..cubicTo(11.8 * s, 9 * s, 12.9 * s, 6.4 * s, 15.7 * s, 4.4 * s)
            ..cubicTo(15.2 * s, 7 * s, 16.1 * s, 8.4 * s, 17.7 * s, 10 * s),
          stroke,
        );

      case AmenityType.ac:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(4 * s, 6 * s, 20 * s, 9 * s),
            Radius.circular(2.4 * s),
          ),
          stroke,
        );
        canvas.drawLine(p(8, 11), p(20, 11), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(9 * s, 18.5 * s)
            ..cubicTo(9 * s, 20.1 * s, 8 * s, 20.5 * s, 8 * s, 22 * s),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(14 * s, 18.5 * s)
            ..cubicTo(14 * s, 20.1 * s, 13 * s, 20.5 * s, 13 * s, 22 * s),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(19 * s, 18.5 * s)
            ..cubicTo(19 * s, 20.1 * s, 18 * s, 20.5 * s, 18 * s, 22 * s),
          stroke,
        );

      case AmenityType.playground:
        canvas.drawCircle(p(14, 14), 9.2 * s, stroke);
        final diamondStroke = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(
          Path()
            ..moveTo(14 * s, 4.8 * s)
            ..lineTo(17.6 * s, 10 * s)
            ..lineTo(14 * s, 13.2 * s)
            ..lineTo(10.4 * s, 10 * s)
            ..close(),
          diamondStroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(4.9 * s, 12.6 * s)
            ..lineTo(10 * s, 10.2 * s)
            ..lineTo(11.3 * s, 15 * s)
            ..lineTo(7 * s, 18.2 * s)
            ..close(),
          diamondStroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(23.1 * s, 12.6 * s)
            ..lineTo(18 * s, 10.2 * s)
            ..lineTo(16.7 * s, 15 * s)
            ..lineTo(21 * s, 18.2 * s)
            ..close(),
          diamondStroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(9 * s, 22.6 * s)
            ..lineTo(11.3 * s, 18 * s)
            ..lineTo(16.7 * s, 18 * s)
            ..lineTo(19 * s, 22.6 * s),
          diamondStroke,
        );

      case AmenityType.bedrooms:
        canvas.drawPath(
          Path()
            ..moveTo(4.5 * s, 20 * s)
            ..lineTo(4.5 * s, 9.5 * s)
            ..lineTo(14 * s, 4 * s)
            ..lineTo(23.5 * s, 9.5 * s)
            ..lineTo(23.5 * s, 20 * s),
          stroke,
        );
        canvas.drawLine(p(4.5, 20), p(23.5, 20), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(11 * s, 20 * s)
            ..lineTo(11 * s, 15 * s)
            ..lineTo(17 * s, 15 * s)
            ..lineTo(17 * s, 20 * s),
          stroke,
        );

      case AmenityType.bathrooms:
        canvas.drawPath(
          Path()
            ..moveTo(6 * s, 12 * s)
            ..lineTo(6 * s, 7.5 * s)
            ..arcToPoint(p(8.5, 5), radius: Radius.circular(2.5 * s))
            ..lineTo(10 * s, 5 * s),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3.5 * s, 12 * s, 21 * s, 4 * s),
            Radius.circular(1.6 * s),
          ),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(6.5 * s, 16 * s)
            ..lineTo(6.5 * s, 19.5 * s)
            ..arcToPoint(p(10, 23), radius: Radius.circular(3.5 * s))
            ..lineTo(18 * s, 23 * s)
            ..arcToPoint(p(21.5, 19.5), radius: Radius.circular(3.5 * s), clockwise: false)
            ..lineTo(21.5 * s, 16 * s),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant AmenityIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
