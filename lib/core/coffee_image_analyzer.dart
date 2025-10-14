import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import 'constellation_pattern.dart';

class CoffeeAnalysisResult {
  CoffeeAnalysisResult({
    required this.isValid,
    this.reason,
    this.constellation,
    this.cupConfidence = 0,
    this.groundsConfidence = 0,
  });

  final bool isValid;
  final String? reason;
  final ConstellationPattern? constellation;
  final double cupConfidence;
  final double groundsConfidence;
}

class CoffeeImageAnalyzer {
  Future<CoffeeAnalysisResult> analyze(Uint8List bytes) async {
    return Future<CoffeeAnalysisResult>(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason: 'Görsel çözümlenemedi. Desteklenmeyen format olabilir.',
        );
      }

      final width = decoded.width;
      final height = decoded.height;
      final totalPixels = width * height;
      if (totalPixels < 120 * 120) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason: 'Görsel çok küçük görünüyor. Daha net bir fincan fotoğrafı yükleyin.',
        );
      }

      final stride = max(1, sqrt(totalPixels / 60000).round());
      var sampleCount = 0;
      var brightCount = 0;
      var darkCount = 0;
      var brownishCount = 0;
      var innerShadowCount = 0;
      final List<_SamplePoint> groundsSamples = [];

      final center = Offset(width / 2, height / 2);
      final detectionRadius = min(width, height) * 0.35;

      for (var y = 0; y < height; y += stride) {
        for (var x = 0; x < width; x += stride) {
          final pixel = decoded.getPixel(x, y);
          final r = img.getRed(pixel);
          final g = img.getGreen(pixel);
          final b = img.getBlue(pixel);
          final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;

          sampleCount++;
          if (luma > 185) {
            brightCount++;
          }
          if (luma < 92) {
            darkCount++;
          }

          final isBrown =
              r > 45 && g > 25 && b < 120 && r > g * 0.9 && r > b * 1.15;
          if (isBrown && luma < 130) {
            brownishCount++;
          }

          final point = Offset(x.toDouble(), y.toDouble());
          if ((point - center).distance <= detectionRadius && luma < 130) {
            innerShadowCount++;
          }

          if (isBrown && luma < 125) {
            final normalized = Offset(x / width, y / height);
            final weight = (155 - luma).clamp(0, 155) / 155;
            final angle = atan2(normalized.dy - 0.5, normalized.dx - 0.5);
            groundsSamples.add(
              _SamplePoint(
                position: normalized,
                intensity: weight,
                angle: angle,
              ),
            );
          }
        }
      }

      if (sampleCount == 0) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason: 'Görsel okunamadı.',
        );
      }

      final brightRatio = brightCount / sampleCount;
      final darkRatio = darkCount / sampleCount;
      final brownRatio = brownishCount / sampleCount;
      final innerShadowRatio =
          innerShadowCount / max(1, (pi * detectionRadius * detectionRadius) /
              (stride * stride));

      final cupConfidence = brightRatio.clamp(0, 1) * 0.6 + innerShadowRatio * 0.4;
      final groundsConfidence = (darkRatio * 0.4 + brownRatio * 0.6).clamp(0, 1);

      if (cupConfidence < 0.24) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason:
              'Fincan şekli algılanamadı. Fotoğrafın üstten veya hafif açılı çekildiğinden emin olun.',
        );
      }

      if (groundsConfidence < 0.18) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason:
              'Telve yoğunluğu çok düşük görünüyor. Telvesiz veya boş bir fincan olabilir.',
        );
      }

      groundsSamples.sort((a, b) => b.intensity.compareTo(a.intensity));
      if (groundsSamples.length > 160) {
        groundsSamples.removeRange(160, groundsSamples.length);
      }

      if (groundsSamples.length < 8) {
        return CoffeeAnalysisResult(
          isValid: false,
          reason: 'Telve izleri yeterince belirgin değil. Fincanı yeniden fotoğraflayın.',
        );
      }

      groundsSamples.sort((a, b) => a.angle.compareTo(b.angle));
      final desiredPoints = min(9, max(6, groundsSamples.length ~/ 6));
      final step = max(1, groundsSamples.length ~/ desiredPoints);
      final List<Offset> constellationPoints = [];
      for (var i = 0; i < groundsSamples.length &&
          constellationPoints.length < desiredPoints; i += step) {
        constellationPoints.add(groundsSamples[i].position);
      }

      final bounds = _boundsFromPoints(constellationPoints);
      final pattern = ConstellationPattern(
        points: constellationPoints,
        boundingBox: bounds,
        sparkSeed: bytes.hashCode ^ totalPixels,
      );

      return CoffeeAnalysisResult(
        isValid: true,
        cupConfidence: cupConfidence,
        groundsConfidence: groundsConfidence,
        constellation: pattern,
      );
    });
  }

  Rect _boundsFromPoints(List<Offset> points) {
    var minX = 1.0;
    var minY = 1.0;
    var maxX = 0.0;
    var maxY = 0.0;
    for (final point in points) {
      minX = min(minX, point.dx);
      minY = min(minY, point.dy);
      maxX = max(maxX, point.dx);
      maxY = max(maxY, point.dy);
    }
    final padding = 0.04;
    minX = (minX - padding).clamp(0.0, 1.0);
    minY = (minY - padding).clamp(0.0, 1.0);
    maxX = (maxX + padding).clamp(0.0, 1.0);
    maxY = (maxY + padding).clamp(0.0, 1.0);
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

class _SamplePoint {
  _SamplePoint({
    required this.position,
    required this.intensity,
    required this.angle,
  });

  final Offset position;
  final double intensity;
  final double angle;
}
