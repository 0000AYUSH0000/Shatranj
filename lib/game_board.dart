import 'package:chess/chess_provider.dart';
import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/square_tile.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:provider/provider.dart';
import 'values.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  @override
  void initState() {
    super.initState();
    //initialize the board
    Provider.of<ChessProvider>(context, listen: false).initializeBoard();
  }

  @override
  Widget build(BuildContext context) {
    //get an instance of the chess provider
    var gameLogic = Provider.of<ChessProvider>(context, listen: true);

    const gridDelegate =
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8);
    return Scaffold(
      backgroundColor: blackTileColor,
      body: SafeArea(
        child: Column(
          children: [
            // WHITE PIECES TAKEN
            Expanded(
              child: GridView.builder(
                itemCount: gameLogic.whiteKilledPieces.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  return DeadPiece(
                    imagePath: gameLogic.whiteKilledPieces[index]!.imagePath,
                    isWhite: true,
                  );
                },
              ),
            ),
            // SHOW WHOSE TURN IT IS
            Text(
              gameLogic.isWhiteTurn ? "White's Turn:" : "Black's Turn",
              style: TextStyle(fontSize: 18, color: whiteTileColor),
            ),
            // GAME STATUS
            gameLogic.checkStatus
                ? const Text(
                    "CHECK!",
                    style: TextStyle(fontSize: 18, color: Colors.redAccent),
                  )
                : const SizedBox(
                    height: 0,
                  ),

            const SizedBox(
              height: 8,
            ),
            // CHESS BOARD
            Expanded(
              flex: 3,
              child: GridView.builder(
                itemCount: 8 * 8,
                gridDelegate: gridDelegate,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // get the row and col position of this square
                  int row = index ~/ 8;
                  int col = index % 8;

                  // check if the square is selected
                  bool isSelected = row == gameLogic.selectedRow &&
                      col == gameLogic.selectedCol;

                  // check if this square is a valid move
                  bool isValidMove = false;

                  for (var position in gameLogic.validMoves) {
                    // compare row and col
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }
                  return SquareTile(
                    isWhite: isWhite(index),
                    piece: gameLogic.board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    row: row,
                    col: col,
                  );
                },
              ),
            ),
            // BLACK PIECES TAKEN
            Expanded(
              child: GridView.builder(
                itemCount: gameLogic.blackKilledPieces.length,
                gridDelegate: gridDelegate,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return DeadPiece(
                    imagePath: gameLogic.blackKilledPieces[index]!.imagePath,
                    isWhite: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
