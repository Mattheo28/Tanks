//Class representing the shell/missile shot by tanks
final class Missile {
  // The missile is represented by a rectangle
  PVector position, velocity, gravity, wind ;
  int missileWidth, missileHeight, moveIncrement ;  
  //the damping variable to represent drag in the air
  float damping;
  
  Missile(int x, int y, int missileWidth, int missileHeight, int moveIncrement, float damping) {
    position = new PVector(x, y) ;
    velocity = new PVector(0, 0);
    gravity = new PVector(0, 0.2);
    wind = new PVector(0, 0);
    this.missileWidth = missileWidth ;
    this.missileHeight = missileHeight ;
    this.moveIncrement = moveIncrement ;
    this.damping = damping;
  }
  
  int getX() {return (int)position.x ;}
  int getY() {return (int)position.y ;}
  PVector getGravity() {return gravity;}
  
  // reuse this object rather than go through object creation
  void reset(int x, int y, float gunX, float gunY, float str, float windSpeed) {
    position.x = x ;
    position.y = y ;
    //divide strength by 200 for game to flow nicely
    float strength = str/200;
    //divide velocity force by 5 for game to flow nicely
    velocity = new PVector(gunX * strength/5,gunY * strength/5);
    gravity = new PVector(0, 0.2);
    //divide windspeed by 1000 for game to flow nicely
    wind = new PVector(windSpeed/1000, 0);
  }
  
  // The missile is displayed as a rectangle
  void draw() {
    //add vectors to missile's position
    position.add(velocity);
    velocity.add(gravity);
    velocity.add(wind);
    velocity.mult(damping);
    fill(200) ;
    rect(position.x, position.y, missileWidth, missileHeight) ;
  }
  
  //Returns true if not out of play area
  boolean move() {
    return position.x <= displayWidth && position.y <= displayHeight && position.x >= 0;
  }  
}
