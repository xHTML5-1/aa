import 'dart:math';
import 'dart:ui';

class ConstellationPattern {
  ConstellationPattern({
    required this.points,
    required this.boundingBox,
    required this.sparkSeed,
  });

  final List<Offset> points;
  final Rect boundingBox;
  final int sparkSeed;

  List<Offset> scaledPoints(Size size) {
    return points
        .map(
          (offset) => Offset(
            offset.dx * size.width,
            offset.dy * size.height,
          ),
        )
        .toList(growable: false);
  }

  Rect scaledBounds(Size size) {
    return Rect.fromLTRB(
      boundingBox.left * size.width,
      boundingBox.top * size.height,
      boundingBox.right * size.width,
      boundingBox.bottom * size.height,
    );
  }

  Iterable<Offset> jitteredPoints(Size size, double magnitude) sync* {
    final rng = Random(sparkSeed);
    for (final point in scaledPoints(size)) {
      final dx = (rng.nextDouble() - 0.5) * magnitude;
      final dy = (rng.nextDouble() - 0.5) * magnitude;
      yield Offset(point.dx + dx, point.dy + dy);
    }
  }
}
