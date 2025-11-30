import 'dart:math';
import 'package:flutter/material.dart';

class CustomMindMapLeft extends StatelessWidget {
  final String centerLabel;
  final List<String> children;

  const CustomMindMapLeft({
    super.key,
    required this.centerLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Left-aligned compact mind map: anchor the center node on the left and
    // arrange child nodes on the right-side semicircle so the map stays
    // compact and usable on mobile devices.
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final double deviceWidth = media.size.width;

        final double availableWidth =
            (constraints.hasBoundedWidth && constraints.maxWidth.isFinite)
            ? constraints.maxWidth
            : deviceWidth;

        // Map occupies up to 60% of available width but never more than 360px.
        final double mapWidth = (availableWidth * 0.6).clamp(
          120.0,
          min(360.0, deviceWidth),
        );
        final double mapHeight = mapWidth * 0.9;

        final int count = children.length;

        final double centerNodeSize = (mapWidth * 0.28).clamp(48.0, 140.0);
        final double childNodeSize = (mapWidth * 0.16).clamp(36.0, 100.0);
        final double radius = (mapWidth - centerNodeSize) * 0.6;

        // Base positions
        final double leftPadding = 8.0;
        final double centerY = mapHeight / 2;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(mapWidth, mapHeight),
                  painter: LinePainter(
                    center: Offset(leftPadding + centerNodeSize / 2, centerY),
                    count: count,
                    radius: radius,
                  ),
                ),

                Positioned(
                  left: leftPadding,
                  top: centerY - centerNodeSize / 2,
                  child: _buildNode(
                    centerLabel,
                    isCenter: true,
                    size: centerNodeSize,
                  ),
                ),

                for (int i = 0; i < count; i++)
                  Positioned(
                    left: (() {
                      final double angle = (count == 1)
                          ? 0
                          : (-pi / 2) + (pi * i / max(1, count - 1));
                      final double cx =
                          leftPadding + centerNodeSize + radius * 0.6;
                      return cx + cos(angle) * radius - childNodeSize / 2;
                    })(),
                    top: (() {
                      final double angle = (count == 1)
                          ? 0
                          : (-pi / 2) + (pi * i / max(1, count - 1));
                      final double cy = centerY;
                      return cy + sin(angle) * radius - childNodeSize / 2;
                    })(),
                    child: _buildNode(children[i], size: childNodeSize),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode(String label, {bool isCenter = false, double? size}) {
    final double nodeSize = size ?? (isCenter ? 120.0 : 100.0);
    return Container(
      width: nodeSize,
      height: nodeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCenter ? Colors.blue : Colors.white,
        shape: BoxShape.circle,
        border: isCenter ? null : Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Tamil',
          color: isCenter ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: isCenter ? (nodeSize * 0.14) : (nodeSize * 0.12),
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

    if (count <= 0) return;

    for (int i = 0; i < count; i++) {
      final double angle = (count == 1)
          ? 0
          : (-pi / 2) + (pi * i / max(1, count - 1));
      final Offset childOffset = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(center, childOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.radius != radius ||
        oldDelegate.center != center;
  }
}
