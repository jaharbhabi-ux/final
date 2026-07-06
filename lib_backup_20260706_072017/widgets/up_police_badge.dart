import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class UPPoliceBadge extends StatelessWidget {
  final double size;

  const UPPoliceBadge({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: ShieldPainter(
              leftColor: const Color(0xFF0F2D59), // Rich Police Navy
              rightColor: const Color(0xFF8C1D1D), // Deep Crimson Red
              borderColor: AppTheme.accentGold,
            ),
          ),
          // Emblem center icon - Gold Star
          Positioned(
            top: size * 0.22,
            child: Icon(
              Icons.star_rounded,
              color: AppTheme.accentGold,
              size: size * 0.45,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          // Subtle highlight lines inside the shield
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  final Color borderColor;

  ShieldPainter({
    required this.leftColor,
    required this.rightColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw left half of the shield
    final leftPath = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width * 0.1, 0)
      ..lineTo(0, height * 0.15)
      ..lineTo(0, height * 0.55)
      ..quadraticBezierTo(0, height * 0.82, width / 2, height)
      ..lineTo(width / 2, 0)
      ..close();

    final leftPaint = Paint()
      ..color = leftColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftPath, leftPaint);

    // Draw right half of the shield
    final rightPath = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width * 0.9, 0)
      ..lineTo(width, height * 0.15)
      ..lineTo(width, height * 0.55)
      ..quadraticBezierTo(width, height * 0.82, width / 2, height)
      ..lineTo(width / 2, 0)
      ..close();

    final rightPaint = Paint()
      ..color = rightColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // Draw outer gold border
    final borderPath = Path()
      ..moveTo(width * 0.1, 0)
      ..lineTo(width * 0.9, 0)
      ..lineTo(width, height * 0.15)
      ..lineTo(width, height * 0.55)
      ..quadraticBezierTo(width, height * 0.82, width / 2, height)
      ..quadraticBezierTo(0, height * 0.82, 0, height * 0.55)
      ..lineTo(0, height * 0.15)
      ..close();

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
