import 'package:chess/chess_provider.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SquareTile extends StatelessWidget {
  const SquareTile({super.key,required this.isWhite, this.piece, required this.isSelected, required this.isValidMove, required this.row, required this.col});
  final bool isSelected;
  final ChessPiece? piece;
  final bool isWhite;
  final bool isValidMove;
  final int row;
  final int col;

  @override
  Widget build(BuildContext context) {
    var gameLogic = Provider.of<ChessProvider>(context, listen: false);
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
      onTap:() => gameLogic.selectPiece(row, col,context),
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