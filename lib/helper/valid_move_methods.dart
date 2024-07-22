import 'helper_methods.dart';


//function to calculate valid moves for a pawn
List<List<int>> getValidPawnMoves(int row, int col, var board) {
  List<List<int>> validMoves = [];
  int direction = board[row][col]!.isWhite ? -1 : 1; //direction of movement
  int newRow = row + direction;

  //pawns can move one step forward if square is empty and two steps if it is their first move
  if (isInBoard(newRow, col) && board[newRow][col] == null) {
    validMoves.add([newRow, col]);
    if ((row == 1 && !board[row][col]!.isWhite) ||
        (row == 6 && board[row][col]!.isWhite)) {
      newRow += direction;
      if (isInBoard(newRow, col) && board[newRow][col] == null) {
        validMoves.add([newRow, col]);
      }
    }
  }

  newRow=row+direction;
//pawns can capture diagonally
  if (isInBoard(newRow, col - 1) &&
      board[newRow][col - 1] != null &&
      board[newRow][col - 1]!.isWhite != board[row][col]!.isWhite) {
    validMoves.add([newRow, col - 1]);
  }
//pawns can capture diagonally
  if (isInBoard(newRow, col + 1) &&
      board[newRow][col + 1] != null &&
      board[newRow][col + 1]!.isWhite != board[row][col]!.isWhite) {
    validMoves.add([newRow, col + 1]);
  }

  return validMoves;
}

//function to calculate valid moves for a rook
List<List<int>> getValidRookMoves(
    int row, int col, var board) {
  List<List<int>> validMoves = [];
  var directions = [
    [1, 0],
    [-1, 0],
    [0, 1],
    [0, -1]
  ];    //check for vertical and horizontal direction

  //check for vertical and horizontal direction
  for (var direction in directions) {
    int newRow = row + direction[0];
    int newCol = col + direction[1];
    while (isInBoard(newRow, newCol)) {
      if (board[newRow][newCol] == null) {
        validMoves.add([newRow, newCol]);
      } else {
        if (board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
          validMoves.add([newRow, newCol]);
        }
        break;
      }
      newRow += direction[0];
      newCol += direction[1];
    }
  }

  return validMoves;
}

//function to calculate valid moves for a knight
List<List<int>> getValidKnightMoves(int row, int col, var board) {
  List<List<int>> validMoves = [];
  var directions = [
    [2, 1],
    [2, -1],
    [-2, 1],
    [-2, -1],
    [1, 2],
    [1, -2],
    [-1, 2],
    [-1, -2]
  ];                      //check for all possible moves of a knight

  for (var direction in directions) {
    int newRow = row + direction[0];
    int newCol = col + direction[1];
    if (isInBoard(newRow, newCol)) {
      if (board[newRow][newCol] == null ||
          board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
        validMoves.add([newRow, newCol]);
      }
    }
  }

  return validMoves;
}

//function to calculate valid moves for a bishop
List<List<int>> getValidBishopMoves(int row, int col, var board) {
  List<List<int>> validMoves = [];
  var directions = [
    [1, 1],                         //check for all possible moves of a bishop
    [1, -1],
    [-1, 1],
    [-1, -1]
  ];

  for (var direction in directions) {
    int newRow = row + direction[0];
    int newCol = col + direction[1];
    while (isInBoard(newRow, newCol)) {
      if (board[newRow][newCol] == null) {
        validMoves.add([newRow, newCol]);
      } else {
        if (board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
          validMoves.add([newRow, newCol]);
        }
        break;
      }
      newRow += direction[0];
      newCol += direction[1];
    }
  }
  return validMoves;
}

//function to calculate valid moves for a queen
List<List<int>> getValidQueenMoves(int row, int col, var board) {
  List<List<int>> validMoves = [];
  validMoves.addAll(getValidRookMoves(row, col, board));
  validMoves.addAll(getValidBishopMoves(row, col, board));
  return validMoves;
}

//function to calculate valid moves for a king
List<List<int>> getValidKingMoves(int row, int col, var board) {
  List<List<int>> validMoves = [];
  var directions = [
    [1, 0],
    [-1, 0],
    [0, 1],                 //check for all possible moves of a king
    [0, -1],
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1]
  ];

  for (var direction in directions) {
    int newRow = row + direction[0];
    int newCol = col + direction[1];
    if (isInBoard(newRow, newCol)) {
      if (board[newRow][newCol] == null ||
          board[newRow][newCol]!.isWhite != board[row][col]!.isWhite) {
        validMoves.add([newRow, newCol]);
      }
    }
  }

  return validMoves;
}
