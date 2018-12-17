//Class representing a button for the user to make choices
final class Button {
  // Position of button
  int rectX, rectY;
  // Diameter of rect
  int rectWidth, rectHeight;
  color rectColor, baseColor;
  color rectHighlight;
  boolean rectOver = false;
  String text;
  
  Button(int rectX, int rectY, int rectWidth, int rectHeight, String text) {
    //initialise button colours
    rectColor = color(255);
    rectHighlight = color(51);
    baseColor = color(102);
    this.rectX = rectX;
    this.rectY = rectY;
    this.rectWidth = rectWidth;
    this.rectHeight = rectHeight;
    this.text = text;
  }
  
  void draw() {
    update();
    
    //if the mouse is over the button, change its colour
    if (rectOver) {
      fill(rectHighlight);
    } else {
      fill(rectColor);
    }
    stroke(255);
    rect(rectX, rectY, rectWidth, rectHeight);
    textSize(20);
    fill(0);
    textAlign(CENTER, CENTER);
    text(text, rectX + rectWidth/2, rectY + rectHeight/2);
    
    stroke(0);
  }
  
  void update() {
    if (overRect()) rectOver = true;
    else rectOver = false;
  }
  
  //check if the mouse is over the button
  boolean overRect()  {
    if (mouseX >= rectX && mouseX <= rectX + rectWidth && 
        mouseY >= rectY && mouseY <= rectY + rectHeight) {
      return true;
    } else {
      return false;
    }
  }
}
