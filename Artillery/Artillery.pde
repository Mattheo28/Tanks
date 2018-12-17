import ddf.minim.*; //<>// //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// Some constants used to derive sizes for game elements from display size
private static final int PLAYER_WIDTH_PROPORTION = 20,
                         PLAYER_HEIGHT_PROPORTION = 20,
                         PLAYER_INIT_X_PROPORTION = 10,
                         PLAYER_INCREMENT_PROPORTION = 500 ;
private static final int MISSILE_WIDTH_PROPORTION = 4,
                         MISSILE_HEIGHT_PROPORTION = 4,
                         MISSILE_INCREMENT_PROPORTION = 5 ;
private static final int BLOCK_WIDTH_PROPORTION = 30,
                         BLOCK_HEIGHT_PROPORTION = 30,
                         NUMBER_OF_BLOCKS = 300;
private static final float DAMPING = .995f ;

Tank player ;
Tank player_one ;
Tank player_two ;
Missile missile ;
//booleans used to decide what to draw on the screen
boolean firing, movingLeft, movingRight, pause, movingUp, movingDown, powering, game_over;
int playerWidth, playerHeight, playerInitX, playerTwoInitX, blockWidth, blockHeight, missileWidth, missileHeight, player_one_score, player_two_score;
int num_rows, num_cols;
float power, windSpeed;
int power_inc;
Block[][] blocks ;
int playerStart;
Button btn_single, btn_twoplayer, btn_easy, btn_medium, btn_hard, btn_menu;
//game settings
boolean single_player, two_player, easy, medium, hard;
//Audio files
Minim minim;
AudioPlayer tankFire;
AudioPlayer tankExplode;
AudioPlayer win;

// Display the main menu where the user selects whether they want to play single player or two player, with the rules
void setup() {
  fullScreen() ; 
  btn_single = new Button(displayWidth/2 - 170, displayHeight/3, 340, 80, "SINGLE PLAYER");
  btn_twoplayer = new Button(displayWidth/2 - 170, displayHeight/3 + 200, 340, 80, "TWO PLAYER");
  btn_menu = new Button(displayWidth/2 - 170, displayHeight/3 + 200, 340, 80, "MENU");
  single_player = false;
  two_player = false;
  easy = false;
  medium = false;
  hard = false;
  game_over = false;
  //initialise who is starting and the scores
  playerStart = 1;
  player_one_score = 0;
  player_two_score = 0;
}

// Display the menu where the user selects what difficulty the AI should play at
void setupDifficultyScreen() {
  btn_easy = new Button(displayWidth/2 - 170, displayHeight/3, 340, 80, "EASY");
  btn_medium = new Button(displayWidth/2 - 170, displayHeight/3 + 200, 340, 80, "MEDIUM");
  btn_hard = new Button(displayWidth/2 - 170, displayHeight/3 + 400, 340, 80, "HARD");
}

// Display the game elements
void setupGame() {
  blockHeight = displayHeight/BLOCK_HEIGHT_PROPORTION;
  blockWidth = displayHeight/BLOCK_WIDTH_PROPORTION;
  //decide on the number of rows and columns for the blocks
  num_rows = displayWidth/blockWidth;    
  num_cols = displayHeight/PLAYER_HEIGHT_PROPORTION;
  blocks = new Block[num_rows][num_cols];      
  int increment = displayWidth/PLAYER_INCREMENT_PROPORTION;  
  //create the randomly generated blocks
  for(int i = 0;i < NUMBER_OF_BLOCKS; i += 1) {
    //randomly decide which row the block will be in
    int rrow = int (random(0,num_rows - 1));
    //find the column the block will be in (the next available spot in the row)
    for(int j = 0;j < num_cols; j += 1) {
      if (blocks[rrow][j] == null) {
        blocks[rrow][j] = new Block(rrow * blockWidth, displayHeight - blockHeight - (j * blockHeight), blockWidth, blockHeight, rrow, j, increment);
        break;
      }
    }
  }
  // initialise the players
  playerWidth = displayWidth/PLAYER_WIDTH_PROPORTION ;
  playerHeight = displayHeight/PLAYER_HEIGHT_PROPORTION ;
  playerInitX = displayWidth/PLAYER_INIT_X_PROPORTION - playerWidth/2 ;
  playerTwoInitX = displayWidth * PLAYER_INIT_X_PROPORTION/(PLAYER_INIT_X_PROPORTION + 1) - playerWidth/2 ;
  int playerInitY = displayHeight - playerHeight - (getBlockUnderTank(playerInitX) * blockHeight);
  int playerTwoInitY = displayHeight - playerHeight - (getBlockUnderTank(playerTwoInitX) * blockHeight);
  player_one = new Tank(1, playerInitX, playerInitY,
                          playerWidth, playerHeight, increment, 100) ;
  player_two = new Tank(2, playerTwoInitX, playerTwoInitY,
                              playerWidth, playerHeight, increment, 98) ;
  //make player two the AI if single player was chosen
  if (single_player) player_two.makeAI();
  if (playerStart == 1) player = player_one;
  else player = player_two;
  // not initially firing, but initialise missile object
  missileWidth = playerWidth/MISSILE_WIDTH_PROPORTION;
  missileHeight = playerHeight/MISSILE_HEIGHT_PROPORTION;
  missile = new Missile(0,0, missileWidth, missileHeight, MISSILE_INCREMENT_PROPORTION, DAMPING) ;
  firing = false ;
  movingLeft = false ;
  movingRight = false ;
  pause = false ;
  movingUp = false;
  movingDown = false;
  powering = false;
  power = 0;
  power_inc = 1;
  //randomly decide the windspeed between -100 and 100 km/h (realistic wind speed)
  windSpeed = int (random(-100,100));
  //load in audio files
  minim = new Minim(this);
  try {
    tankFire = minim.loadFile("TankShot.mp3");
    tankExplode = minim.loadFile("TankExplode.mp3");
    win = minim.loadFile("Win.mp3");  
  } catch (NullPointerException e) {
    e.printStackTrace();
    tankFire = null;
    tankExplode = null;
    win = null;      
  }
  draw();
  //if the AI is starting, make the AI play
  if (player.isAI()) AIfire();
}

// update and render
void draw() {
  background(0) ;  
  //if neither single player or two player has been chosen, draw the buttons for the user to choose and display the rules
  if (!single_player && !two_player) {
    btn_single.draw();
    btn_twoplayer.draw();
    fill(255);
    textSize(45);
    text("Controls", displayWidth/5, displayHeight/3);
    text("Rules", displayWidth * 4/5, displayHeight/3);
    textSize(25);
    text("Left arrow to move tank to the left", displayWidth/5, displayHeight/3 + 60);
    text("Right arrow to move tank to the right", displayWidth/5, displayHeight/3 + 100);
    text("Up arrow to move tank gun up", displayWidth/5, displayHeight/3 + 140);
    text("Right arrow to move tank gun down", displayWidth/5, displayHeight/3 + 180);
    text("Spacebar to start powering up missile strength", displayWidth/5, displayHeight/3 + 220);
    text("Spacebar again to select strength", displayWidth/5, displayHeight/3 + 260);
    text("First player to reach at least 10 points", displayWidth * 4/5, displayHeight/3 + 50);
    text("and have 2 more points than the other player wins", displayWidth * 4/5, displayHeight/3 + 80);
    return;
  } 
  //if single player was chosen but not a difficulty, draw the buttons for the user to choose
  else if (single_player && !easy && !medium && !hard) {
    btn_easy.draw();
    btn_medium.draw();
    btn_hard.draw();
    return;
  }
  //if the game is over, show the button to go back to the menu
  if (game_over) {
    btn_menu.draw();    
    if (win != null) {
      tankExplode.close();
      win.rewind();  
      win.play();  //<>//
    } 
  }
  //draw the blocks
  for(int i = 0;i < num_rows;i += 1) {
    for(int j = 0;j < num_cols; j += 1) {
      if (blocks[i][j] != null) {
        blocks[i][j].draw();
        //if the block should be moving downwards
        if (blocks[i][j].movingDown) blocks[i][j].moveDown();
      }
    }
  }
  fill(255);
  stroke(255);
  player_one.draw();
  player_two.draw();
  //if the player is allowed to move
  if (!pause) {    
    if (movingLeft) {
      player.moveLeft() ;
      //check for collisions and resolve
      if (tankHitTank(player_one, player_two)) player.moveRight();
      if (tankHitBlockSide(player)) player.moveRight();
    }
    else if (movingRight) {
      player.moveRight() ; 
      //check for collisions and resolve
      if (tankHitTank(player_one, player_two)) player.moveLeft();
      if (tankHitBlockSide(player)) player.moveLeft();
    }
    else if (movingUp) player.moveGunUp();
    else if (movingDown) player.moveGunDown();
    //check if there is a block under the tank
    if (tankOnBlock(player)) player.moveUp();
    else player.moveDown();
    player.draw() ;
  }
  // the missile
  if (firing) {
    Block block = missileHitBlock();
    //check for collisions with tanks and blocks, and act as necessary
    if (missileHitTank(player_one)) {
      firing = false;    
      //update score
      player_two_score += 1;     
      playerStart = 1;
      if (tankExplode != null) {
        tankExplode.rewind();
        tankExplode.play();
      }
      //start new round if no one has won yet
      if (getWinner() == 0) setupGame();
    } else if (missileHitTank(player_two)) {
      firing = false;   
      player_one_score += 1;   
      playerStart = 2;
      if (tankExplode != null) {
        tankExplode.rewind();
        tankExplode.play();
      }
      //start new round if no one has won yet
      if (getWinner() == 0) setupGame();
    } else if (block != null) {
      firing = false;
      rearrangeBlocks(block.getRow(), block.getCol());
      changeTurn();
      pause = false;
    } else if (missile.move()) {
      missile.draw() ;
    } else {
      firing = false ;
      changeTurn();
      pause = false;
    }
  }
  //control the power up
  if (powering) {
    if (power >= 500) power_inc = -10;
    if (power <= 0) power_inc = 10;
    power += power_inc;
  }
  fill(255);
  textSize(25);
  //show necessary text to user on screen
  text(player_one_score, playerInitX, 50);
  text(player_two_score, playerTwoInitX, 50);
  text("Power: " + power, displayWidth/3, 100);
  text("Elevation angle: " + player.getAngle(), displayWidth/2, 100);
  text("Wind: " + abs(windSpeed) + "km/h", displayWidth * 2/3, 100);
  // draw the line of arrow indicating wind speed
  line(displayWidth * 2/3 - 30, 80, displayWidth * 2/3 + 100, 80);
  //draw the triangle of arrow indicating wind speed
  if (windSpeed > 0) {
    pushMatrix();
    translate(displayWidth * 2/3 + 100, 80);
    triangle(0, 0, -10, 5, -10, -5);
    popMatrix();
  } else {
    pushMatrix();
    translate(displayWidth * 2/3 - 30, 80);
    triangle(0, 0, 10, 5, 10, -5);
    popMatrix();
  }  
  //if we have a winner, display win message
  if (getWinner() > 0) {
    textSize(45);
    game_over = true;      
    text("Player " + getWinner() + " wins!", displayWidth/2, 300);    
  }
  //otherwise show whose turn it is
  else text("Player " + player.getId() + "'s turn!", displayWidth/2, 300);
}

//Act accordingly when a button is selected
void mousePressed() {
  //go back to menu
  if (game_over && btn_menu.overRect()) {
    setup();
    return;
  }
  //no buttons should be available at this point
  if (two_player || (single_player && (easy || medium || hard))) return;
  //choose difficulty
  if (single_player) {
    if (!easy && !medium && !hard) {
      if (btn_easy.overRect()) {
        easy = true;
        setupGame();
      }    
      if (btn_medium.overRect()) {
        medium = true;
        setupGame();
      }    
      if (btn_hard.overRect()) {
        hard = true;
        setupGame();
      }    
    }
  }
  //choose single or two player
  else if (btn_single.overRect()) {
    single_player = true;
    setupDifficultyScreen();
  }
  else if (btn_twoplayer.overRect()) {
    two_player = true;
    setupGame();
  }
}

// Read keyboard for input
void keyPressed() {
  //ignore keyboard input if game settings haven't been chosen
  if ((!single_player && !two_player) || game_over) return;
  // space to power up and fire
  if (key == ' ' && !player.isAI()) {
    if (!firing) {
      if (powering) {
        fire(power) ;
        powering = false;
      }
      else powering = true;    
    }
  }  
  if (key == CODED && !player.isAI()) {
     switch (keyCode) {
       case LEFT :
         movingLeft = true ;
         break ;
       case RIGHT :
         movingRight = true ;
         break ;
       case UP :
         movingUp = true;
         break;
       case DOWN :
         movingDown = true;
         break;
     }
  }
}

//Stop actions when keys are released
void keyReleased() {
  if ((!single_player && !two_player) || game_over) return;
  if (key == CODED && !player.isAI()) {
     switch (keyCode) {
       case LEFT :
         movingLeft = false ;
         break ;
       case RIGHT :
         movingRight = false ;
         break ;
       case UP :
         movingUp = false;
         break;
       case DOWN :
         movingDown = false;
         break;
     }
  }  
}

//void stop() {
//  tankFire.close();
//  tankExplode.close();
//  win.close();
//  minim.stop();
//}

//get the highest block in the row to see where tank should be placed
int getBlockUnderTank(int tank_x_coord) {
  int highestBlock = 0;
  //whether or not we found the row of blocks the tank touches
  boolean found = false;
  //go through all the rows to see which ones the tank touches
  for(int i = 0;i < num_rows;i += 1) {
    if ((i * blockWidth >= tank_x_coord || (i * blockWidth) + blockWidth - 1 >= tank_x_coord) && !found) found = true;
    //if we tank isn't touching the rows anymore
    if (found && i * blockWidth > (tank_x_coord + playerWidth)) {
      found = false;
      break;
    }
    //if we found the row of blocks the tank touches, find highest block
    if (found) {
      for(int j = 0;j < num_cols;j += 1) {
        if (blocks[i][j] == null) {
          if (highestBlock < j) highestBlock = j;
          break;
        }
      }
    }
  }
  return highestBlock;
}

// initiate firing with a given strength
void fire(float strength) {
  if (!firing) {
    missile.reset((int)player.getGunTipX(),
                  (int)player.getGunTipY() - player.playerHeight/MISSILE_WIDTH_PROPORTION, 
                  player.getGunTipX() - player.getGunInitX(), 
                  player.getGunTipY() - player.getGunInitY(),
                  strength, windSpeed) ;
    firing = true ;
    pause = true ;
    if (tankFire != null) {
      tankFire.rewind();  
      tankFire.play();
  }
  }
}

//change whose turn it is
void changeTurn() {
  if (player.getId() == 1) player = player_two;
  else player = player_one;
  //reset power and choose new random windspeed
  power = 0;
  windSpeed = int (random(-100,100));
  draw();
  //make the AI play if it is its turn
  if (player.isAI() && !game_over) AIfire();
}

//Check if the missile has hit a tank
boolean missileHitTank(Tank tank) {
  if (tank.getX() + tank.getWidth() >= missile.getX() &&     // r1 right edge past r2 left
      tank.getX() <= missile.getX() + missileWidth &&       // r1 left edge past r2 right
      tank.getY() + tank.getHeight() >= missile.getY() &&       // r1 top edge past r2 bottom
      tank.getY() <= missile.getY() + missileHeight) {       // r1 bottom edge past r2 top
      return true;
  }
  return false;
}

//Check if a tank has hit the other tank
boolean tankHitTank(Tank tank_one, Tank tank_two) {
  if (tank_one.getX() + tank_one.getWidth() >= tank_two.getX() &&     // r1 right edge past r2 left
      tank_one.getX() <= tank_two.getX() + tank_two.getWidth() &&       // r1 left edge past r2 right
      tank_one.getY() + tank_one.getHeight() >= tank_two.getY() &&       // r1 top edge past r2 bottom
      tank_one.getY() <= tank_two.getY() + tank_two.getHeight()) {       // r1 bottom edge past r2 top
      return true;
  }
  return false;
}

//Check if the tank has hit the side of a block
boolean tankHitBlockSide(Tank tank) {
  return getBlockAt(tank.getX(), tank.getY() + 1) != null || 
         getBlockAt(tank.getX() + playerWidth, tank.getY() + 1) != null || 
         getBlockAt(tank.getX(), tank.getY() + playerHeight - 1) != null ||
         getBlockAt(tank.getX() + playerWidth, tank.getY() + playerHeight - 1) != null;
}

//Check if the tank is on top of a block
boolean tankOnBlock(Tank tank) {
  for(int i = tank.getX() + 1; i <= tank.getX() + playerWidth - 1; i++) {
    if (getBlockAt(i, tank.getY() + playerHeight) != null) return true; 
  }
  return false;
}

//Get the block that the missile hit (returns null if no block was hit)
Block missileHitBlock() {
  Block block = getBlockAt(missile.getX(), missile.getY());
  if (block != null) return block;
  block = getBlockAt(missile.getX() + missileWidth, missile.getY());
  if (block != null) return block;
  block = getBlockAt(missile.getX(), missile.getY() + missileHeight);
  if (block != null) return block;
  block = getBlockAt(missile.getX() + missileWidth, missile.getY() + missileHeight);
  if (block != null) return block;
  return null;
}

//Reorganise the blocks, removing the ones that are hit and making the blocks above the hit block move down
void rearrangeBlocks(int row, int col) {
  for(int i = col + 1; i < num_cols; i += 1) {
    if (blocks[row][i] != null) {
      //move each block down one by one above the hit block
      blocks[row][i].setNewY(blocks[row][i - 1].getY(), blocks[row][i - 1].getCol());
      blocks[row][i - 1] = blocks[row][i];
    } 
    //reached the top of the row of blocks
    else {
      blocks[row][i - 1] = null;
      return;
    }
  }
}

//Get the block at given coordinates, otherwise null
Block getBlockAt(int x, int y) {  
  for(int i = 0;i < num_rows;i += 1) {
    for(int j = 0;j < num_cols; j += 1) {
      if (blocks[i][j] != null) {
        int block_x = i * blockWidth;
        int block_y = displayHeight - blockHeight - (j * blockHeight);
        if (x >= block_x &&     // r1 right edge past r2 left
            x <= block_x + blockWidth &&       // r1 left edge past r2 right
            y >= block_y &&       // r1 top edge past r2 bottom
            y <= block_y + blockHeight) {       // r1 bottom edge past r2 top
            return blocks[i][j];
        }
      }
    }
  }
  return null;
}

//Check if the given coordinates collide with the given tank
boolean hitTank(float startX, float startY, float w, float h, Tank tank) {
  if (tank.getX() + tank.getWidth() >= startX &&     // r1 right edge past r2 left
      tank.getX() <= startX + w &&       // r1 left edge past r2 right
      tank.getY() + tank.getHeight() >= startY &&       // r1 top edge past r2 bottom
      tank.getY() <= startY + h) {       // r1 bottom edge past r2 top
      return true;
  }
  return false;
}

//Check if the given coordinates collide with the given block
boolean hitBlock(int startX, int startY, int w, int h) {
  Block block = getBlockAt(startX, startY);
  if (block != null) return true;
  block = getBlockAt(startX + w, startY);
  if (block != null) return true;
  block = getBlockAt(startX, startY + h);
  if (block != null) return true;
  block = getBlockAt(startX + w, startY + h);
  if (block != null) return true;
  return false;
}

//Make the AI fire
void AIfire() {
  //Get initial gun and missile positions
  float misPosX = player.getGunTipX();
  float misPosY = player.getGunTipY() - player.playerHeight/MISSILE_WIDTH_PROPORTION;
  float gunPosX = player.getGunTipX() - player.getGunInitX();
  float gunPosY = player.getGunTipY() - player.getGunInitY();
  boolean pwrFound = false;
  //start with a power of 50
  float pwr = 50;
  //remember the initial angle
  float initAngle = player.angle;
  //Setup vectors as they are used by the missile
  PVector position = new PVector(misPosX, misPosY);
  PVector velocity = new PVector(gunPosX * (pwr/200)/5,gunPosY * (pwr/200)/5);
  PVector gravity = new PVector(0, 0.2);
  PVector wind = new PVector(windSpeed/1000, 0);
  //Look for the power to shoot at
  while (!pwrFound) {
    //Add vectors
    position.add(velocity);
    velocity.add(gravity);
    velocity.add(wind);
    velocity.mult(DAMPING);
    //if we hit the tank, we found the perfect power
    if (hitTank(position.x, position.y, missileWidth, missileHeight, player_one)) pwrFound = true;
    //if the missile is out of the play area or we have hit a block, change the power/angle
    else if (position.y > player_one.getY() + playerHeight || hitBlock((int) position.x, (int) position.y, missileWidth, missileHeight)) {
      //increment power by 10
      pwr += 10;
      // if we reach max power, reset the power and change the gun angle
      if (pwr > 500) {
        pwr = 10;
        float prevAngle = player.angle;
        //move the gun up 5 times to make things faster
        for(int i = 0; i < 6; i++) {
          player.moveGunUp();
        }
        //if we reached the max angle
        if (player.angle == prevAngle) {
          //o winning shot is found, set default power and angle
          pwrFound = true;
          player.setAngle(initAngle);
          pwr = 300;
        }
        //reset gun and missile positions
        misPosX = player.getGunTipX();
        misPosY = player.getGunTipY() - player.playerHeight/MISSILE_WIDTH_PROPORTION;
        gunPosX = player.getGunTipX() - player.getGunInitX();
        gunPosY = player.getGunTipY() - player.getGunInitY();
      }
      position = new PVector(misPosX, misPosY);
      velocity = new PVector(gunPosX * (pwr/200)/5,gunPosY * (pwr/200)/5);
      draw();
    }
  }
  //randomly decide on a power value close to the one we need, based on the difficulty
  if (easy) pwr = random(pwr - 50, pwr + 50);
  else if (medium) pwr = random(pwr - 20, pwr + 20);
  else if (hard) pwr = random(pwr - 5, pwr + 5);
  player.setAngle(initAngle);
  fire(pwr);
}

//get the winner of the game, returns 0 if no one has won
int getWinner() {
  //there is a winner when one of the players has reached 10 and has at least 2 more points than the other player
  if (player_one_score >= 10 && player_one_score - player_two_score >= 2) return 1;
  else if (player_two_score >= 10 && player_two_score - player_one_score >= 2) return 2;
  else return 0;
}
