// In-Class Activity 06 — Drawing with Flutter
// Student: Ernest Fistik
// Date: September 26, 2026

import 'dart:math' show pi;
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
  Color faceColor = Colors.yellow.shade600;

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
                    faceColor: faceColor,
                    eyeRadius: eyeRadius,
                    eyeGap: eyeGap,
                    showBlush: showBlush,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in [
                        Colors.yellow.shade600,
                        Colors.lightBlue.shade300,
                        Colors.orange.shade400,
                        Colors.green.shade300,
                      ])
                        ChoiceChip(
                          label: const Text('  '),
                          backgroundColor: c,
                          selectedColor: c,
                          selected: faceColor == c,
                          onSelected: (_) => setState(() => faceColor = c),
                        ),
                    ],
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
  });

  final double mood;
  final Color faceColor;
  final double eyeRadius;
  final double eyeGap;
  final bool showBlush;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

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
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * eyeGap;
    canvas.drawCircle(Offset(c.dx - eyeDx, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(c.dx + eyeDx, eyeY), eyeRadius, eyePaint);
    
    // 5) Mouth 
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final t = (mood - 0.5) * 2;

    final mouthY = c.dy + r * 0.3;
    final halfWidth = r * 0.45;

    final mouthPath = Path()
      ..moveTo(c.dx - halfWidth, mouthY)
      ..quadraticBezierTo(
        c.dx,
        mouthY + t * r * 0.8,
        c.dx + halfWidth,
        mouthY,
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant SmileyPainter old) {
    return old.mood != mood ||
        old.faceColor != faceColor ||
        old.eyeRadius != eyeRadius ||
        old.eyeGap != eyeGap ||
        old.showBlush != showBlush;
  }
}