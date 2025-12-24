import 'dart:math';
import 'package:flutter/material.dart';

/// ----------------------------
/// DATA MODEL (SAME AS main.dart)
/// ----------------------------
class MindMapNode {
  final String label;
  final List<MindMapNode> children;

  MindMapNode({
    required this.label,
    this.children = const [],
  });
}

/// ----------------------------
/// MULTI-LEVEL MIND MAP
/// ----------------------------
class CustomMindMap extends StatelessWidget {
  final MindMapNode root;

  const CustomMindMap({
    super.key,
    required this.root,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final double level1Radius = isMobile ? 110 : 160;
    final double level2Radius = isMobile ? 180 : 250;

    final double centerSize = isMobile ? 90 : 120;
    final double level1Size = isMobile ? 70 : 95;
    final double level2Size = isMobile ? 55 : 75;

    final double canvasSize = level2Radius * 2 + centerSize + 60;
    final Offset center = Offset(canvasSize / 2, canvasSize / 2);

    return Align(
      alignment: isMobile ? Alignment.centerLeft : Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: SizedBox(
            width: canvasSize,
            height: canvasSize,
            child: Stack(
              children: [
                /// CONNECTION LINES
                CustomPaint(
                  size: Size(canvasSize, canvasSize),
                  painter: MultiLevelLinePainter(
                    root: root,
                    center: center,
                    level1Radius: level1Radius,
                    level2Radius: level2Radius,
                  ),
                ),

                /// CENTER NODE
                Positioned(
                  left: center.dx - centerSize / 2,
                  top: center.dy - centerSize / 2,
                  child: _buildNode(
                    root.label,
                    size: centerSize,
                    isCenter: true,
                  ),
                ),

                /// LEVEL 1 + LEVEL 2 NODES
                ..._buildLevelNodes(
                  center: center,
                  level1Radius: level1Radius,
                  level2Radius: level2Radius,
                  level1Size: level1Size,
                  level2Size: level2Size,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ----------------------------
  /// BUILD ALL LEVEL NODES
  /// ----------------------------
  List<Widget> _buildLevelNodes({
    required Offset center,
    required double level1Radius,
    required double level2Radius,
    required double level1Size,
    required double level2Size,
  }) {
    final List<Widget> widgets = [];
    final int level1Count = root.children.length;

    for (int i = 0; i < level1Count; i++) {
      final double angle1 = 2 * pi * i / level1Count;

      final Offset level1Pos = Offset(
        center.dx + cos(angle1) * level1Radius,
        center.dy + sin(angle1) * level1Radius,
      );

      /// Level 1 Node
      widgets.add(
        Positioned(
          left: level1Pos.dx - level1Size / 2,
          top: level1Pos.dy - level1Size / 2,
          child: _buildNode(root.children[i].label, size: level1Size),
        ),
      );

      final level2Nodes = root.children[i].children;
      final int level2Count = level2Nodes.length;

      for (int j = 0; j < level2Count; j++) {
        final double spread = pi / 5;
        final double angle2 =
            angle1 - spread / 2 + spread * (j / max(1, level2Count - 1));

        final Offset level2Pos = Offset(
          center.dx + cos(angle2) * level2Radius,
          center.dy + sin(angle2) * level2Radius,
        );

        /// Level 2 Node
        widgets.add(
          Positioned(
            left: level2Pos.dx - level2Size / 2,
            top: level2Pos.dy - level2Size / 2,
            child: _buildNode(level2Nodes[j].label, size: level2Size),
          ),
        );
      }
    }

    return widgets;
  }

  /// ----------------------------
  /// NODE UI
  /// ----------------------------
  Widget _buildNode(
    String label, {
    required double size,
    bool isCenter = false,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isCenter ? Colors.blue : Colors.white,
        shape: BoxShape.circle,
        border:
            isCenter ? null : Border.all(color: Colors.blue, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.15,
          fontWeight: FontWeight.bold,
          color: isCenter ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

/// ----------------------------
/// MULTI-LEVEL LINE PAINTER
/// ----------------------------
class MultiLevelLinePainter extends CustomPainter {
  final MindMapNode root;
  final Offset center;
  final double level1Radius;
  final double level2Radius;

  MultiLevelLinePainter({
    required this.root,
    required this.center,
    required this.level1Radius,
    required this.level2Radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    final int level1Count = root.children.length;

    for (int i = 0; i < level1Count; i++) {
      final double angle1 = 2 * pi * i / level1Count;

      final Offset level1Pos = Offset(
        center.dx + cos(angle1) * level1Radius,
        center.dy + sin(angle1) * level1Radius,
      );

      /// Center → Level 1
      canvas.drawLine(center, level1Pos, paint);

      final level2Nodes = root.children[i].children;
      final int level2Count = level2Nodes.length;

      for (int j = 0; j < level2Count; j++) {
        final double spread = pi / 5;
        final double angle2 =
            angle1 - spread / 2 + spread * (j / max(1, level2Count - 1));

        final Offset level2Pos = Offset(
          center.dx + cos(angle2) * level2Radius,
          center.dy + sin(angle2) * level2Radius,
        );

        /// Level 1 → Level 2
        canvas.drawLine(level1Pos, level2Pos, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
