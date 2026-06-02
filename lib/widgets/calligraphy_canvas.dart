import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CalligraphyCanvas extends StatelessWidget {
  final String char;
  final double fontSize;
  final double height;
  final double? width;
  final bool showDecorativeBorder;
  final bool showSeal;

  const CalligraphyCanvas({
    super.key,
    required this.char,
    this.fontSize = 120.0,
    this.height = 240.0,
    this.width,
    this.showDecorativeBorder = true,
    this.showSeal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.radiusLg,
        border: showDecorativeBorder
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 2.0)
            : Border.all(color: AppColors.border, width: 1.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.background.withRed(245).withGreen(240).withBlue(230),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Elegant textured grid background lines (traditional Chinese/Vietnamese calligraphy practice sheets)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _CalligraphyGridPainter(),
              ),
            ),
          ),
          
          // Big Calligraphy Character
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  char,
                  textAlign: TextAlign.center,
                  style: AppStyles.calligraphyStyle.copyWith(
                    fontSize: fontSize,
                    color: AppColors.ink,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // Red artist/booth stamp seal in the corner for extreme premium authenticity
          if (showSeal)
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.destructive, width: 1.5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  "Ấn\nKý",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.destructive,
                    height: 1.1,
                  ),
                ),
              ),
            ),

          // Top corner decorative brush/badge
          Positioned(
            top: 12.0,
            left: 12.0,
            child: Text(
              "書", // Calligraphy character symbol
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: AppColors.ink.withValues(alpha: 0.2),
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalligraphyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw circular border
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.4,
      paint,
    );

    // Draw central quadrant cross lines
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
