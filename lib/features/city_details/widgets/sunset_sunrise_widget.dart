import 'package:flutter/material.dart';

class SunriseSunsetWidget extends StatelessWidget {
  final int sunrise;
  final int sunset;
  final DateTime currentTime;

  const SunriseSunsetWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final sunriseDt = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
    final sunsetDt = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
    final isDay =
        currentTime.isAfter(sunriseDt) && currentTime.isBefore(sunsetDt);
    final totalDayLength = sunsetDt.difference(sunriseDt).inMinutes;
    final elapsedTime = currentTime.difference(sunriseDt).inMinutes;
    double progress = elapsedTime / totalDayLength;

    // Clamp progress between 0 and 1
    progress = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: 150, // Set a fixed height for the widget
      width: double.infinity, // Take full width
      child: CustomPaint(
        painter: SunriseSunsetPainter(
          progress: progress,
          isDay: isDay,
        ),
      ),
    );
  }
}

class SunriseSunsetPainter extends CustomPainter {
  final double progress;
  final bool isDay;

  SunriseSunsetPainter({
    required this.progress,
    required this.isDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final dottedPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    const startX = 0.0;
    final endX = size.width;

    // Draw the curved line
    path.moveTo(startX, centerY);
    path.quadraticBezierTo(size.width / 2, centerY - 50, endX, centerY);

    if (isDay) {
      // Draw continuous line for passed time
      final passedPath = Path();
      passedPath.addPath(path, Offset.zero);
      final metrics = passedPath.computeMetrics().first;
      final length = metrics.length;
      final passedLength = length * progress;

      final passedPathSegment = metrics.extractPath(0, passedLength);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(passedPathSegment, paint);

      // Draw dotted line for remaining time
      drawDottedLine(
          canvas, metrics.extractPath(passedLength, length), dottedPaint);
    } else {
      // Draw dotted line for night
      drawDottedLine(canvas, path, dottedPaint);
    }

    // Draw sun or moon icon
    final iconCenterX = size.width * progress;
    final iconCenterY = centerY - 50;
    const iconRadius = 20.0;

    if (isDay) {
      // Draw sun with shadow
      final sunPaint = Paint()
        ..color = Colors.yellow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(iconCenterX, iconCenterY), iconRadius, sunPaint);
    } else {
      // Draw moon with shadow
      final moonPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(
          Offset(iconCenterX, iconCenterY), iconRadius, moonPaint);
    }
  }

  // Function to draw a dotted line manually
  void drawDottedLine(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double dashWidth = 5; // Length of each dash
      double dashSpace = 5; // Space between dashes
      double start = 0;
      while (start < metric.length) {
        final end = start + dashWidth;
        canvas.drawPath(
          metric.extractPath(start, end),
          paint,
        );
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
