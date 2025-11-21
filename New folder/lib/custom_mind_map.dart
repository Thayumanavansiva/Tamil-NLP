import 'dart:math';
import 'package:flutter/material.dart';

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
    const double radius = 140;
    final double canvasSize = 2 * radius + 200;
    final Offset center = Offset(canvasSize / 2, canvasSize / 2);

    return Center(
      child: SizedBox(
        width: canvasSize,
        height: canvasSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(canvasSize, canvasSize),
              painter: LinePainter(center: center, count: children.length, radius: radius),
            ),
            Positioned(
              left: center.dx - 60,
              top: center.dy - 60,
              child: _buildNode(centerLabel, isCenter: true),
            ),
            for (int i = 0; i < children.length; i++)
              Positioned(
                left: center.dx + cos(2 * pi * i / children.length) * radius - 50,
                top: center.dy + sin(2 * pi * i / children.length) * radius - 50,
                child: _buildNode(children[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(String label, {bool isCenter = false}) {
    return Container(
      width: isCenter ? 120 : 100,
      height: isCenter ? 120 : 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCenter ? Colors.blue : Colors.white,
        shape: BoxShape.circle,
        border: isCenter ? null : Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Tamil',
          color: isCenter ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: isCenter ? 16 : 14,
        ),
      ),
    );
  }
}

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
      final angle = 2 * pi * i / count;
      final Offset childOffset = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, childOffset, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
