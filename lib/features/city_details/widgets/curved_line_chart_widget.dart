import 'package:flutter/material.dart';

class CurvedLineChartWidget extends StatelessWidget {
  final List<double> temperatures;

  const CurvedLineChartWidget({super.key, required this.temperatures})
      : assert(temperatures.length == 5,
            'There must be exactly 5 temperature values.');

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CurvedLineChartPainter(temperatures),
    );
  }
}

class _CurvedLineChartPainter extends CustomPainter {
  final List<double> temperatures;

  _CurvedLineChartPainter(this.temperatures);

  @override
  void paint(Canvas canvas, Size size) {
    const double chartHeight = 5;
    final double chartWidth = size.width;
    const double verticalPadding = 30;

    // Points
    final points = List.generate(
      temperatures.length,
      (index) => Offset(
        chartWidth * (index / (temperatures.length - 1)),
        chartHeight - (temperatures[index] / 5) * chartHeight + verticalPadding,
      ),
    );

    // Line Paint with Gradient for transparency on edges
    final Gradient linePaintGradient = LinearGradient(
      colors: [
        Colors.grey.withOpacity(0.5),
        Colors.grey.withOpacity(0.9),
        Colors.grey.withOpacity(0.5)
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Line Paint with Gradient for transparency on edges
    final Gradient shadowPaintGradient = LinearGradient(
      colors: [
        Colors.grey.withOpacity(0.01),
        Colors.grey.withOpacity(0.1),
        Colors.grey.withOpacity(0.01)
      ],
      stops: const [0.1, 0.5, 1.0],
    );

    // Shadow Paint
    final Paint shadowPaint = Paint()
      ..shader = shadowPaintGradient
          .createShader(Rect.fromLTWH(0, 0, chartWidth, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint linePaint = Paint()
      ..shader = linePaintGradient
          .createShader(Rect.fromLTWH(0, 0, chartWidth, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Path linePath = Path();
    final Path shadowPath = Path();

    // Move to start
    linePath.moveTo(points[0].dx, points[0].dy);
    shadowPath.moveTo(points[0].dx, size.height);
    shadowPath.lineTo(points[0].dx, points[0].dy);

    // Draw cubic Bezier curves for smooth transitions
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final midPoint =
          Offset((prev.dx + current.dx) / 2, (prev.dy + current.dy) / 2);

      linePath.quadraticBezierTo(prev.dx, prev.dy, midPoint.dx, midPoint.dy);
      shadowPath.quadraticBezierTo(prev.dx, prev.dy, midPoint.dx, midPoint.dy);
    }

    // Finalize paths
    linePath.lineTo(points.last.dx, points.last.dy);
    shadowPath.lineTo(points.last.dx, points.last.dy);
    shadowPath.lineTo(points.last.dx, size.height);
    shadowPath.close();

    // shadowPath.moveTo(points[0].dx, size.height);
    // shadowPath.lineTo(points[0].dx, points[0].dy);

    // Draw shadow
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw line
    canvas.drawPath(linePath, linePaint);

    // Draw labels and temperatures
    const textStyleLabel = TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );
    const textStyleTemperature = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    );
    final labels = ['Morning', 'Midday', 'Afternoon', 'Evening', 'Night'];
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < points.length; i++) {
      // Draw temperature
      final temperatureText = '${temperatures[i].round()}°';
      textPainter.text =
          TextSpan(text: temperatureText, style: textStyleTemperature);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, points[i].dy + 10),
      );

      // Draw label
      textPainter.text = TextSpan(text: labels[i], style: textStyleLabel);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, points[i].dy + 30),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
