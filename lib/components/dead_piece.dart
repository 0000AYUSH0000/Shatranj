import 'package:chess/values.dart';
import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});
  final String imagePath;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Image.asset(imagePath,color: isWhite?whitePieceColor:blackPieceColor,),
    );
  }
}
