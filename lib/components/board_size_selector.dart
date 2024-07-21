import 'package:flutter/material.dart';
import 'package:isra/const/constants.dart';
import '../const/colors.dart';

class BoardSizeSelector extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const BoardSizeSelector({
    Key? key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const boardSize = 160.0; // Increased size for better visibility
    final sizePerTile = (boardSize / size).floorToDouble();
    final tileSize = sizePerTile - 10 - (10 / size); // Increased padding
    const tilePadding = 10.0; // Increased padding

    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          width: boardSize,
          height: boardSize,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? textColor : Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: List.generate(size * size, (i) {
              var x = ((i + 1) / size).ceil();
              var y = x - 1;

              var top = y * (tileSize) + (x * tilePadding);
              var z = (i - (size * y));
              var left = z * (tileSize) + ((z + 1) * tilePadding);

              return Positioned(
                top: top,
                left: left,
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isSelected
                            ? Color(textColor.withAlpha(50).value)
                            : Color(emptyTileColor.withAlpha(200).value),
                        isSelected
                            ? Color(textColor.withAlpha(50).value)
                            : Color(emptyTileColor.withAlpha(180).value),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        boardSize), // Increased border radius
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '${geezMap[size.toString()]} x ${geezMap[size.toString()]}',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: isSelected ? textColor : Colors.grey,
              ),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: backgroundColor,
                size: 24,
              ),
            ),
          ),
      ]),
    );
  }
}
