//Class representing a tank
final class Tank {
  // The player's tank is represented as a rectangle, and the tank's gun is represented as a line
  int id;
  PVector position ;
  int playerWidth, playerHeight, moveIncrement, gunLength;
  float gunX, gunY, newX, newY, angle ;
  boolean ai;
  
  Tank(int id, int x, int y, int playerWidth, int playerHeight, int moveIncrement, int initAngle) {
    this.id = id;
    position = new PVector(x, y) ;
    this.playerWidth = playerWidth ;
    this.playerHeight = playerHeight ;
    this.moveIncrement = moveIncrement ;
    this.gunX = position.x + playerWidth/2;
    this.gunY = position.y;
    this.angle = initAngle;
    this.gunLength = playerHeight;
    ai = false;
  }
  
  // getters and setters
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  int getId() {return (int)this.id;}
  int getWidth() {return (int)this.playerWidth;}
  int getHeight() {return (int)this.playerHeight;}
  float getGunInitX() {return (float)this.gunX;}
  float getGunInitY() {return (float)this.gunY;}
  float getGunTipX() {return (float)this.newX;}
  float getGunTipY() {return (float)this.newY;}
  float getAngle() {return (float)this.angle;}
  void setAngle(float angle) {this.angle = angle;}
  boolean isAI() {return this.ai;}
  void makeAI() {ai = true;}
  
  void draw() {
    strokeWeight(1);
    fill(255);
    rect(position.x, position.y, playerWidth, playerHeight) ;
    strokeWeight(4);
    stroke(255);
    gunX = position.x + playerWidth/2;
    gunY = position.y;
    // calculate the end point of the gun
    newX = gunX + cos(angle) * gunLength;
    newY = gunY + sin(angle) * gunLength;
    line(gunX, gunY, newX, newY);
    strokeWeight(1);
  }
  
  // Handle movement
  void moveLeft() {
    position.x -= moveIncrement ;
    if (position.x < 0) position.x = 0 ;
  }
  void moveRight() {
    position.x += moveIncrement ;
    if (position.x > displayWidth-playerWidth) 
      position.x = displayWidth-playerWidth ;
  }  
  void moveDown() {
    position.y += moveIncrement;  
    if (position.y > displayHeight) position.y = displayHeight ;
  }
  void moveUp() {
    position.y -= moveIncrement ;
  }  
  
  void moveGunDown() {
    if (newY >= position.y - 1 && newX < position.x) return;
    angle  -= 0.03;
  }
  
  void moveGunUp() {
    if (newY >= position.y - 1 && newX > position.x) return;
    angle  += 0.03;
  }
}
