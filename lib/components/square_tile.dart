import 'package:chess/components/piece.dart';
import 'package:chess/values.dart';
import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  const SquareTile({super.key,required this.isWhite, this.piece, required this.isSelected, required this.onTap, required this.isValidMove});
  final bool isSelected;
  final ChessPiece? piece;
  final bool isWhite;
  final bool isValidMove;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    //check if the square is selected
    if(isSelected){
      squareColor = Colors.greenAccent;
    }
    else if(isValidMove && piece==null){
      squareColor = Colors.lightGreenAccent;
    }
    else if(piece!=null && isValidMove){
      squareColor = Colors.redAccent;
    }
    else{
      squareColor = isWhite?whiteTileColor:blackTileColor;
    }


    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(4),
        margin: isValidMove?const EdgeInsets.all(5):null,
        color: squareColor,
        child:piece!=null?Image.asset(
            piece!.imagePath,
          color: piece!.isWhite?whitePieceColor:blackPieceColor,
        ):null,
      ),
    );
  }
}