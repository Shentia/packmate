import 'package:flutter/material.dart';
import 'dart:ui';

class TravelBackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const TravelBackgroundWidget({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    const Color(0xFF1A1A2E), // Deep purple
                    const Color(0xFF16213E), // Dark blue
                    const Color(0xFF0F3460), // Medium blue
                  ]
                  : [
                    const Color(0xFF87CEEB), // Sky blue
                    const Color(0xFFE0F6FF), // Light blue
                    const Color(0xFFF0F8FF), // Alice blue
                  ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Animated floating elements
              ...List.generate(
                5,
                (index) => _buildFloatingElement(index, isDark, constraints),
              ),
              // Main content
              child,
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingElement(
    int index,
    bool isDark,
    BoxConstraints constraints,
  ) {
    final icons = [
      Icons.airplanemode_active,
      Icons.location_on,
      Icons.camera_alt,
      Icons.map,
      Icons.beach_access,
    ];

    final positions = [
      const Offset(0.1, 0.2),
      const Offset(0.8, 0.1),
      const Offset(0.9, 0.6),
      const Offset(0.2, 0.8),
      const Offset(0.7, 0.9),
    ];

    return Positioned(
      left: constraints.maxWidth * positions[index].dx,
      top: constraints.maxHeight * positions[index].dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 2000 + (index * 500)),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 10 * (0.5 - value).abs()),
            child: Opacity(
              opacity: 0.1 + (0.1 * value),
              child: Icon(
                icons[index],
                size: 30 + (index * 5),
                color:
                    isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GradientMesh extends StatelessWidget {
  final bool isDark;

  const GradientMesh({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GradientMeshPainter(isDark),
    );
  }
}

class _GradientMeshPainter extends CustomPainter {
  final bool isDark;

  _GradientMeshPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.3, -0.5),
            radius: 1.5,
            colors:
                isDark
                    ? [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.05),
                      Colors.transparent,
                    ]
                    : [
                      Colors.blue.withOpacity(0.15),
                      Colors.cyan.withOpacity(0.1),
                      Colors.transparent,
                    ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add secondary gradient
    final paint2 =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, 0.8),
            radius: 1.2,
            colors:
                isDark
                    ? [
                      Colors.teal.withOpacity(0.08),
                      Colors.green.withOpacity(0.04),
                      Colors.transparent,
                    ]
                    : [
                      Colors.green.withOpacity(0.12),
                      Colors.yellow.withOpacity(0.08),
                      Colors.transparent,
                    ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
