import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/tile.dart';

class AnimatedTile extends StatelessWidget {
  final Tile tile;
  final Animation<double> moveAnimation;
  final Animation<double> scaleAnimation;
  final double size;
  final int boardSize;
  final Widget child;
  final Map<String, double> Function(int) getPosition;

  const AnimatedTile({
    Key? key,
    required this.tile,
    required this.moveAnimation,
    required this.scaleAnimation,
    required this.size,
    required this.boardSize,
    required this.child,
    required this.getPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startPosition = getPosition(tile.index);
    final endPosition = getPosition(tile.nextIndex ?? tile.index);

    return AnimatedBuilder(
      animation: moveAnimation,
      builder: (context, child) {
        final top = lerpDouble(startPosition['top'], endPosition['top'], moveAnimation.value)!;
        final left = lerpDouble(startPosition['left'], endPosition['left'], moveAnimation.value)!;

        return Positioned(
          top: top,
          left: left,
          child: tile.merged
              ? ScaleTransition(
            scale: scaleAnimation,
            child: SizedBox(
              width: size,
              height: size,
              child: child!,
            ),
          )
              : SizedBox(
            width: size,
            height: size,
            child: child!,
          ),
        );
      },
      child: child,
    );
  }
}