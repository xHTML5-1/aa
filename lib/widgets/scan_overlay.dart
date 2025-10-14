import 'package:flutter/material.dart';

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanPainter(progress: animation.value),
        );
      },
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scanHeight = size.height * 0.2;
    final y = (size.height + scanHeight) * progress - scanHeight;

    final rect = Rect.fromLTWH(0, y, size.width, scanHeight);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.0),
        Colors.cyanAccent.withOpacity(0.18),
        Colors.white.withOpacity(0.05),
        Colors.deepPurpleAccent.withOpacity(0.12),
        Colors.black.withOpacity(0.0),
      ],
      stops: const [0, 0.35, 0.5, 0.65, 1],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.screen;
    canvas.drawRect(rect, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.cyanAccent.withOpacity(0.4);

    final borderRect = Rect.fromLTWH(0, y + scanHeight * 0.2, size.width,
        scanHeight * 0.6);
    canvas.drawRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
