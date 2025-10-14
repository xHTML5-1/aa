import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constellation_pattern.dart';

class ConstellationPainter extends CustomPainter {
  ConstellationPainter({
    required this.pattern,
    required this.progress,
  });

  final ConstellationPattern pattern;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.points.isEmpty || progress <= 0) {
      return;
    }
    final clampedProgress = progress.clamp(0.0, 1.0);
    final points = pattern.scaledPoints(size);
    final activeCount = max(2, (points.length * clampedProgress).round());
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < activeCount && i < points.length; i++) {
      final current = points[i];
      path.lineTo(current.dx, current.dy);
    }

    final bounds = pattern.scaledBounds(size);
    final glowStrength = Curves.easeOut.transform(clampedProgress);

    final overlayPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purpleAccent.withOpacity(0.18 * glowStrength),
          Colors.deepPurple.withOpacity(0.04 * glowStrength),
          Colors.transparent,
        ],
        stops: const [0, 0.6, 1],
      ).createShader(bounds.inflate(bounds.width * 0.4));

    canvas.drawRect(bounds.inflate(bounds.width * 0.35), overlayPaint);

    final neonRect = bounds.inflate(16 - 12 * (1 - glowStrength));
    final neonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + 2 * glowStrength
      ..color = Color.lerp(
        Colors.cyanAccent,
        Colors.purpleAccent,
        0.5 + 0.5 * glowStrength,
      )!
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 12 * glowStrength + 4);

    final rectPath = Path()..
        addRRect(RRect.fromRectAndRadius(neonRect, const Radius.circular(28)));
    canvas.drawPath(rectPath, neonPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.purpleAccent.withOpacity(0.22 * glowStrength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 24);

    canvas.drawPath(path, glowPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = Colors.white.withOpacity(0.8);

    canvas.drawPath(path, strokePaint);

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final haloPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.4 * glowStrength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (var i = 0; i < activeCount && i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 12, haloPaint);
      canvas.drawCircle(point, 4.5, nodePaint);
    }

    final sparkMagnitude = 12 * glowStrength;
    final sparks = pattern.jitteredPoints(size, sparkMagnitude);
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyanAccent.withOpacity(0.35 * glowStrength);
    for (final spark in sparks) {
      canvas.drawCircle(spark, 2.2 + glowStrength, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.progress != progress;
  }
}
