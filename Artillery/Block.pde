//Class representing the blocks on the screen
final class Block {
  PVector position ;
  int blockWidth, blockHeight, row, col, moveIncrement, newY ;
  boolean movingDown;
  
  Block(int x, int y, int blockWidth, int blockHeight, int row, int col, int moveIncrement) {
    position = new PVector(x, y) ;
    this.blockWidth = blockWidth ;
    this.blockHeight = blockHeight ;
    this.row = row;
    this.col = col;
    this.moveIncrement = moveIncrement;
    //the new position the block should stop at when falling down
    this.newY = y;
    movingDown = false;
  }
  
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  //this is used for the block to move down
  void setNewY(int newY, int col) {
    this.newY = newY;
    this.col = col;
    movingDown = true;
  }
  int getRow() {return (int)this.row;}
  int getCol() {return (int)this.col;}
  
  // The missile is displayed as a rectangle
  void draw() {
    fill(210,105,30);
    stroke(210,105,30);
    rect(position.x, position.y, blockWidth, blockHeight) ;
  }
  
  //make the block move down until it reaches the right position
  void moveDown() {
    position.y += moveIncrement;  
    if (position.y >= newY) {
      position.y = newY;
      movingDown = false;
    }
  }
}
