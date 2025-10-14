import 'dart:math';

import 'package:flutter/material.dart';

class Starfield extends StatefulWidget {
  const Starfield({super.key, required this.animation});

  final Animation<double> animation;

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _StarfieldState extends State<Starfield> {
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = Random(424242);
    _stars = List.generate(240, (index) {
      return _Star(
        position: Offset(rng.nextDouble(), rng.nextDouble()),
        baseOpacity: 0.15 + rng.nextDouble() * 0.45,
        radius: 0.5 + rng.nextDouble() * 1.8,
        twinkleOffset: rng.nextDouble() * pi * 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarfieldPainter(
            stars: _stars,
            progress: widget.animation.value,
          ),
        );
      },
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.stars, required this.progress});

  final List<_Star> stars;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = progress.clamp(0.0, 1.0);
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0x330D0B1F).withOpacity(0.2 + 0.3 * clamped),
          const Color(0x660E1A3D).withOpacity(0.35 + 0.4 * clamped),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final time = clamped * 6 * pi;
    for (final star in stars) {
      final position = Offset(
        star.position.dx * size.width,
        star.position.dy * size.height,
      );
      final twinkle = (sin(time + star.twinkleOffset) + 1) / 2;
      final opacity = star.baseOpacity + twinkle * (0.6 - star.baseOpacity);
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity.clamp(0.0, 0.9))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(position, star.radius + twinkle * 1.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.stars != stars;
  }
}

class _Star {
  _Star({
    required this.position,
    required this.baseOpacity,
    required this.radius,
    required this.twinkleOffset,
  });

  final Offset position;
  final double baseOpacity;
  final double radius;
  final double twinkleOffset;
}
