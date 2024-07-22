import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square_tile.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:chess/helper/valid_move_methods.dart';
import 'values.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list representing the chessboard,
  late List<List<ChessPiece?>> board;

  // The currently selected piece on the chess board,
  ChessPiece? selectedPiece;

  // The row index of the selected piece
  int selectedRow = -1;

  // The col index of the selected piece
  int selectedCol = -1;

  // A list of valid moves for the currently selected pieces
  // each valid move is represented as a list with 2 elements : row and col
  List<List<int>> validMoves = [];

  // A list of white pieces that have been taken by black pieces
  List<ChessPiece?> whiteKilledPieces = [];

  // A list of black pieces that have been taken by white pieces
  List<ChessPiece?> blackKilledPieces = [];

  // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  // initial position of kings ( keep track of it to make it easier later to see if king is in check )
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

// INITIALIZE BOARD
  void _initializeBoard() {
    // Create a new 2D list to represent the chess board
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = const ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: pawnImg,
      );
      newBoard[6][i] = const ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: pawnImg,
      );

      if (i == 0 || i == 7) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.rook,
          isWhite: false,
          imagePath: rookImg,
        );
        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.rook,
          isWhite: true,
          imagePath: rookImg,
        );
      }



      //place knights
      if (i == 1 || i == 6) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.knight,
          isWhite: false,
          imagePath: knightImg,
        );
        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.knight,
          isWhite: true,
          imagePath: knightImg,
        );
      }

      //place bishops
      if (i == 2 || i == 5) {
        newBoard[0][i] = const ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: false,
          imagePath: bishopImg,
        );
        newBoard[7][i] = const ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: true,
          imagePath: bishopImg,
        );
      }
    }

    // Place queen
    newBoard[0][3] = const ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: queenImg,
    );
    newBoard[7][3] = const ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: queenImg,
    );

    // Place king
    newBoard[0][4] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: kingImg,
    );
    newBoard[7][4] = const ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: kingImg,
    );

    board = newBoard;
  }

// USER SELECTED A PIECE
  void selectPiece(int row, int col) {
    setState(
      () {
        // no piece has been selected yet, this is the first selection
        if (selectedPiece == null && board[row][col] != null) {
          if (board[row][col]!.isWhite == isWhiteTurn) {
            selectedPiece = board[row][col];
            selectedRow = row;
            selectedCol = col;
          }
        }

        // There is a piece already selected, but user can select another one of their piece
        else if (board[row][col] != null &&
            board[row][col]!.isWhite == selectedPiece!.isWhite) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }

        // if there is a piece selected and user taps on a square that is a valid move, move there
        else if (selectedPiece != null &&
            validMoves
                .any((element) => element[0] == row && element[1] == col)) {
          movePiece(row, col);
        }

        // if the piece is selected then calculate the valid moves
        validMoves = calculateRealValidMoves(
          selectedRow,
          selectedCol,
          selectedPiece,
          true,
        );
      },
    );
  }

// CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawns can move forward if the square is not occupied
        candidateMoves = getValidPawnMoves(row, col, board);
        break;

      case ChessPieceType.rook:
        candidateMoves = getValidRookMoves(row, col, board);
        break;

      case ChessPieceType.knight:
        candidateMoves = getValidKnightMoves(row, col, board);
        break;

      case ChessPieceType.bishop:
        candidateMoves = getValidBishopMoves(row, col, board);
        break;

      case ChessPieceType.queen:
        candidateMoves = getValidQueenMoves(row, col, board);
        break;
      case ChessPieceType.king:
        candidateMoves = getValidKingMoves(row, col, board);
        break;
      default:
    }
    return candidateMoves;
  }

// CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all candidate moves, filter out any that would result in check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move to see if it's safe
        if (simulateMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

// MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whiteKilledPieces.add(capturedPiece);
      } else {
        blackKilledPieces.add(capturedPiece);
      }
    }

    // check if the piece being moved is a king
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // promote pawn if it reaches the end of the board
    if (selectedPiece!.type == ChessPieceType.pawn &&
        (newRow == 0 || newRow == 7)) {
      promotePawn(newRow, newCol);
    }

    // see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor:Colors.greenAccent,
            title: const Text("CHECK MATE!"),
            content: Text(
              !isWhiteTurn ? "White Wins!" : "Black Wins!",
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: resetGame,
                child: const Text(
                  "Play again",
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          );
        },
      );
    }

    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

// IS KING IN CHECK?
  bool isKingInCheck(bool isWhiteKing) {
    // get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip the empty square and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);
        // check if the king's position is in this piece's valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

// SIMULATED A FUTURE MOVE TO SEE IF IT'S SAFE
  bool simulateMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king, save it's current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if the piece was the king, restore it original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // if king is in check = true then the move is not safe so return false
    return !kingInCheck;
  }

// IS CHECK MATE?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check, then it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is at least one legal move for any of the player pieces, then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip the empty square and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);
        // check if the king's position is in this piece's valid moves
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above conditions are met, then there is no legal move left to make
    // its check mate
    return true;
  }

// RESET THE GAME
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whiteKilledPieces.clear();
    blackKilledPieces.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  //WHEN A PAWN REACHES THE END OF THE BOARD IT CAN BE PROMOTED TO A QUEEN
  void promotePawn(int row, int col) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.orangeAccent.withOpacity(0.9),
          title: const Text("Promote Pawn"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.queen,
                    isWhite: !isWhiteTurn,
                    imagePath: queenImg,
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Queen"),
              ),
              ElevatedButton(
                onPressed: () {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.rook,
                    isWhite: !isWhiteTurn,
                    imagePath: rookImg,
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Rook"),
              ),
              ElevatedButton(
                onPressed: () {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.bishop,
                    isWhite: !isWhiteTurn,
                    imagePath: bishopImg,
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Bishop"),
              ),
              ElevatedButton(
                onPressed: () {
                  board[row][col] = ChessPiece(
                    type: ChessPieceType.knight,
                    isWhite: !isWhiteTurn,
                    imagePath: knightImg,
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Knight"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: whiteKilledPieces.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  return DeadPiece(
                    imagePath: whiteKilledPieces[index]!.imagePath,
                    isWhite: true,
                  );
                },
              ),
            ),
            // SHOW WHOSE TURN IT IS
            Text(
              isWhiteTurn ? "White's Turn:" : "Black's Turn",
              style: TextStyle(fontSize: 18, color: whiteTileColor),
            ),
            // GAME STATUS
            checkStatus
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
                  bool isSelected = row == selectedRow && col == selectedCol;

                  // check if this square is a valid move
                  bool isValidMove = false;

                  for (var position in validMoves) {
                    // compare row and col
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }
                  return SquareTile(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    onTap: () => selectPiece(row, col),
                    isValidMove: isValidMove,
                  );
                },
              ),
            ),
            // BLACK PIECES TAKEN
            Expanded(
              child: GridView.builder(
                itemCount: blackKilledPieces.length,
                gridDelegate: gridDelegate,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return DeadPiece(
                    imagePath: blackKilledPieces[index]!.imagePath,
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
