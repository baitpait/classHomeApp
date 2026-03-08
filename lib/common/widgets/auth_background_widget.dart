import 'package:flutter/material.dart';
import 'package:hexacom_user/utill/color_resources.dart';

/// Reusable auth screen background: navy base + subtle dot pattern + soft radial gradient.
/// Use as the first layer behind the auth card so login/signup/OTP screens feel consistent.
class AuthBackgroundWidget extends StatelessWidget {
  final Widget child;

  const AuthBackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: ColorResources.navBarNavy),
        CustomPaint(
          size: Size.infinite,
          painter: _AuthDotPatternPainter(),
        ),
        // Soft radial gradient so the center (card area) is slightly brighter
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                ColorResources.navBarNavy.withValues(alpha: 0.85),
                ColorResources.navBarNavy,
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AuthDotPatternPainter extends CustomPainter {
  static const double _spacing = 28.0;
  static const double _dotRadius = 1.2;
  static const double _opacity = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: _opacity)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width + _spacing; x += _spacing) {
      for (double y = 0; y < size.height + _spacing; y += _spacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
