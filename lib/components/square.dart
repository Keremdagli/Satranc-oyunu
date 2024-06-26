import 'package:flutter/material.dart';
import 'piece.dart';

class Square extends StatelessWidget {
  final void Function()? onTap;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isWhite;
  final bool isValidMove;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.onTap,
    required this.isSelected,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else {
      squareColor = isWhite ? Colors.grey[500] : Colors.grey[600];
    }

    if (isValidMove && piece != null) {
      squareColor = Colors.red[400];
    } else if (isValidMove) {
      squareColor = Colors.green[200];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 4 : 0),
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                color: piece!.isWhite ? Colors.white : Colors.black,
              )
            : null,
      ),
    );
  }
}
