bool isWhite(int index) {
  return (index ~/ 8 + index % 8) % 2 == 0;
}

bool isInBoard(int row,int col){
  return row>=0 && row<8 && col>=0 && col<8;
}