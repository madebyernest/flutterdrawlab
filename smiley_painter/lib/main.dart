// In-Class Activity 06 — Drawing with Flutter
// Student: Ernest Fistik
// Date: September 26, 2026

import 'dart:math' show pi, atan2;
import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

enum FaceType { classic, sleepy, surprised }

/// Smooth face color: blue (sad) -> yellow (neutral) -> orange (happy).
Color moodColor(double mood) {
  final blue = Colors.lightBlue.shade300;
  final yellow = Colors.yellow.shade600;
  final orange = Colors.orange.shade400;
  if (mood < 0.5) {
    return Color.lerp(blue, yellow, mood / 0.5)!;
  }
  return Color.lerp(yellow, orange, (mood - 0.5) / 0.5)!;
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8; // 0.0 sad → 1.0 happy
  double eyeRadius = 14;
  double eyeGap = 0.35; // fraction of face radius
  bool showBlush = true;
  bool showHat = true;
  FaceType faceType = FaceType.classic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: SmileyPainter(
                    mood: mood,
                    faceColor: moodColor(mood),
                    eyeRadius: eyeRadius,
                    eyeGap: eyeGap,
                    showBlush: showBlush,
                    showHat: showHat,
                    faceType: faceType,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SegmentedButton<FaceType>(
                    segments: const [
                      ButtonSegment(
                          value: FaceType.classic, label: Text('Classic')),
                      ButtonSegment(
                          value: FaceType.sleepy, label: Text('Sleepy')),
                      ButtonSegment(
                          value: FaceType.surprised, label: Text('Surprised')),
                    ],
                    selected: {faceType},
                    onSelectionChanged: (Set<FaceType> s) =>
                        setState(() => faceType = s.first),
                  ),
                  const SizedBox(height: 12),
                  Text('Mood: ${mood.toStringAsFixed(2)}'),
                  Slider(
                    value: mood,
                    onChanged: (double v) => setState(() => mood = v),
                  ),
                  Text('Eye radius: ${eyeRadius.toStringAsFixed(0)}'),
                  Slider(
                    value: eyeRadius,
                    min: 6,
                    max: 24,
                    onChanged: (double v) => setState(() => eyeRadius = v),
                  ),
                  Text('Eye gap: ${eyeGap.toStringAsFixed(2)}'),
                  Slider(
                    value: eyeGap,
                    min: 0.2,
                    max: 0.5,
                    onChanged: (double v) => setState(() => eyeGap = v),
                  ),
                  SwitchListTile(
                    title: const Text('Show blush'),
                    value: showBlush,
                    onChanged: (bool v) => setState(() => showBlush = v),
                  ),
                  SwitchListTile(
                    title: const Text('Show hat'),
                    value: showHat,
                    onChanged: (bool v) => setState(() => showHat = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceColor,
    required this.eyeRadius,
    required this.eyeGap,
    required this.showBlush,
    required this.showHat,
    required this.faceType,
  });

  final double mood;
  final Color faceColor;
  final double eyeRadius;
  final double eyeGap;
  final bool showBlush;
  final bool showHat;
  final FaceType faceType;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    final dark = Paint()..color = Colors.black87;
    final darkStroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // 1) Face
    canvas.drawCircle(c, r, Paint()..color = faceColor);

    // 2) Border
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // 3) Blush
    if (showBlush) {
      final blush = Paint()..color = Colors.pink.withOpacity(0.35);
      final blushY = c.dy + r * 0.15;
      final blushDx = r * 0.6;
      Rect blushRect(Offset center) =>
          Rect.fromCenter(center: center, width: r * 0.35, height: r * 0.2);
      canvas.drawOval(blushRect(Offset(c.dx - blushDx, blushY)), blush);
      canvas.drawOval(blushRect(Offset(c.dx + blushDx, blushY)), blush);
    }

    // 4) Eyes
    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * eyeGap;
    final leftEye = Offset(c.dx - eyeDx, eyeY);
    final rightEye = Offset(c.dx + eyeDx, eyeY);

    switch (faceType) {
      case FaceType.classic:
        canvas.drawCircle(leftEye, eyeRadius, dark);
        canvas.drawCircle(rightEye, eyeRadius, dark);
        break;
      case FaceType.sleepy:
        // Closed eyes: small downward-curving arcs
        for (final e in [leftEye, rightEye]) {
          final rect = Rect.fromCenter(
            center: e,
            width: eyeRadius * 2,
            height: eyeRadius * 1.2,
          );
          canvas.drawArc(rect, 0.1 * pi, 0.8 * pi, false, darkStroke);
        }
        break;
      case FaceType.surprised:
        // Bigger eyes: white with outline and a dark pupil
        final big = eyeRadius * 1.4;
        final outline = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        for (final e in [leftEye, rightEye]) {
          canvas.drawCircle(e, big, Paint()..color = Colors.white);
          canvas.drawCircle(e, big, outline);
          canvas.drawCircle(e, big * 0.45, dark);
        }
        break;
    }

    // 5) Mouth
    final mouthY = c.dy + r * 0.3;
    final halfWidth = r * 0.45;

    if (faceType == FaceType.surprised) {
      // Round open mouth
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, mouthY + r * 0.1),
          width: r * 0.3,
          height: r * 0.4,
        ),
        dark,
      );
    } else {
      var t = (mood - 0.5) * 2;
      if (faceType == FaceType.sleepy) t *= 0.4;
      final s = t * r * 0.4;
      final a = s.abs();

      if (a < 0.5) {
        // Neutral: straight line
        canvas.drawLine(
          Offset(c.dx - halfWidth, mouthY),
          Offset(c.dx + halfWidth, mouthY),
          darkStroke,
        );
      } else {
        // Circle arc through the two fixed endpoints with bulge 'a'
        final R = (halfWidth * halfWidth + a * a) / (2 * a);
        final phi = atan2(R - a, halfWidth);
        final sweep = pi - 2 * phi;

        if (s > 0) {
          // Smile: circle center above the chord, draw the bottom arc
          final center = Offset(c.dx, mouthY - (R - a));
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: R),
            phi,
            sweep,
            false,
            darkStroke,
          );
        } else {
          // Frown: circle center below the chord, draw the top arc
          final center = Offset(c.dx, mouthY + (R - a));
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: R),
            phi - pi,
            sweep,
            false,
            darkStroke,
          );
        }
      }
    }

    // 6) Hat
    if (showHat) {
      final hatPaint = Paint()..color = Colors.indigo;
      final hatTop = c.dy - r * 1.15;
      canvas.drawRect(
        Rect.fromLTRB(c.dx - r * 0.5, hatTop, c.dx + r * 0.5, c.dy - r * 0.75),
        hatPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(
            c.dx - r * 0.8, c.dy - r * 0.75, c.dx + r * 0.8, c.dy - r * 0.6),
        hatPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter old) {
    return old.mood != mood ||
        old.faceColor != faceColor ||
        old.eyeRadius != eyeRadius ||
        old.eyeGap != eyeGap ||
        old.showBlush != showBlush ||
        old.showHat != showHat ||
        old.faceType != faceType;
  }
}