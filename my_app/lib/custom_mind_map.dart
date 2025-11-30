import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive Mind Map (Mobile + Tablet + Desktop)
/// Auto-fits, aligns left on small screens, avoids overflow.
class CustomMindMap extends StatelessWidget {
  final String centerLabel;
  final List<String> children;

  const CustomMindMap({
    super.key,
    required this.centerLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    /// Dynamic sizing based on screen
    final double radius = isMobile ? 90 : 140;
    final double centerSize = isMobile ? 90 : 120;
    final double childSize = isMobile ? 70 : 100;

    /// Canvas auto-adjusts to content, not full page
    final double canvasSize = radius * 2 + centerSize + 40;
    final Offset center = Offset(canvasSize / 2, canvasSize / 2);

    return Align(
      alignment: isMobile ? Alignment.centerLeft : Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: SizedBox(
            width: canvasSize,
            height: canvasSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// Draw connecting lines
                CustomPaint(
                  size: Size(canvasSize, canvasSize),
                  painter: LinePainter(
                    center: center,
                    count: children.length,
                    radius: radius,
                  ),
                ),

                /// Center node
                Positioned(
                  left: center.dx - centerSize / 2,
                  top: center.dy - centerSize / 2,
                  child: _buildNode(
                    centerLabel,
                    isCenter: true,
                    size: centerSize,
                  ),
                ),

                /// Child nodes (around the circle)
                for (int i = 0; i < children.length; i++)
                  Positioned(
                    left:
                        center.dx +
                        cos(2 * pi * i / children.length) * radius -
                        childSize / 2,
                    top:
                        center.dy +
                        sin(2 * pi * i / children.length) * radius -
                        childSize / 2,
                    child: _buildNode(children[i], size: childSize),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(
    String label, {
    bool isCenter = false,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCenter ? Colors.blue : Colors.white,
        shape: BoxShape.circle,
        border: isCenter ? null : Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isCenter ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.16,
        ),
      ),
    );
  }
}

/// Draws lines between center and child nodes
class LinePainter extends CustomPainter {
  final Offset center;
  final int count;
  final double radius;

  LinePainter({
    required this.center,
    required this.count,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    for (int i = 0; i < count; i++) {
      final double angle = 2 * pi * i / count;
      final Offset child = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, child, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
