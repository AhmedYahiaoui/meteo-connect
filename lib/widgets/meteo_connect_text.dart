import 'package:flutter/material.dart';

class MeteoConnectText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  const MeteoConnectText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.6
              ..color = Colors.black,
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w500,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
