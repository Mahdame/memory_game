import 'package:flutter/material.dart';

class MedalPainter extends CustomPainter {
  final double shinePosition;

  MedalPainter({required this.shinePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final double ribbonWidth = size.width / 3;
    final double ribbonLength = size.height / 3;
    final double medalRadius = size.width / 4;
    final Offset medalCenter = Offset(size.width / 2, size.height / 1.5);

    // Paint for the ribbon
    final ribbonPaint = Paint()..color = Colors.red;

    // Define the path for the ribbon
    Path ribbonPath = Path()
      ..moveTo(medalCenter.dx - ribbonWidth / 2, 0)
      ..lineTo(medalCenter.dx + ribbonWidth / 2, 0)
      ..lineTo(medalCenter.dx + ribbonWidth / 2 - 10, ribbonLength)
      ..lineTo(medalCenter.dx - ribbonWidth / 2 + 10, ribbonLength)
      ..close();

    // Draw the ribbon
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Draw the second part of the ribbon
    Path ribbonPathBottom = Path()
      ..moveTo(medalCenter.dx - ribbonWidth / 2 + 10, ribbonLength)
      ..lineTo(medalCenter.dx + ribbonWidth / 2 - 10, ribbonLength)
      ..lineTo(medalCenter.dx + ribbonWidth / 2 - 20, ribbonLength * 2)
      ..lineTo(medalCenter.dx - ribbonWidth / 2 + 20, ribbonLength * 2)
      ..close();

    canvas.drawPath(ribbonPathBottom, ribbonPaint);

    // Paint for the medal
    final medalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.yellow, Colors.amber],
      ).createShader(
        Rect.fromCircle(
          center: medalCenter,
          radius: medalRadius,
        ),
      );

    // Draw the medal
    canvas.drawCircle(medalCenter, medalRadius, medalPaint);

    // Paint for the shiny effect
    final shinyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.shade200.withOpacity(0.8),
          Colors.yellow.shade600.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3],
        tileMode: TileMode.decal,
        center: Alignment(shinePosition * 2 - 1, 0.0),
        radius: 2.0,
      ).createShader(Rect.fromCircle(
        center: medalCenter,
        radius: medalRadius,
      ));

    // Draw the shiny effect as a circle
    canvas.drawCircle(medalCenter, medalRadius, shinyPaint);

    // Paint for the inner circle of the medal
    final innerCirclePaint = Paint()..color = Colors.amber[100]!;

    // Draw the inner circle of the medal
    canvas.drawCircle(medalCenter, medalRadius / 1.5, innerCirclePaint);

    // Define text style: font size, color, etc.
    final textStyle = TextStyle(
      color: Colors.amber,
      shadows: [
        Shadow(
          color: Colors.grey[500]!,
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ],
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );

    // Create a TextSpan with the text and style
    final textSpan = TextSpan(
      text: '1',
      style: textStyle,
    );

    // Create a TextPainter to layout and draw the text
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Layout the text based on the size available
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    // Calculate the position to draw the text in the center of the medal
    final textOffset = Offset(
      medalCenter.dx - (textPainter.width / 2),
      medalCenter.dy - (textPainter.height / 2),
    );

    // Draw the text onto the canvas
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant MedalPainter oldDelegate) => true; // Return true to allow repainting
}
