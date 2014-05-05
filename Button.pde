class Button {  
  color hoverColorButton = color(16, 187, 244);
  color normalColorButton = color(8, 126, 167);
  color clickedColorButton = color(91, 208, 247);
  color labelColorButton = color(255);

  color hoverColorLetterBox = color(175, 232, 251);
  color normalColorLetterBox = color(255);
  color clickedColorLetterBox = color(91, 208, 247);
  color labelColorLetterBox = color(8, 126, 167);

  int buttonX, buttonY, buttonW, buttonH, buttonR, buttonFontsize;
  boolean isLetterBox;
  PFont buttonFont;
  String buttonLabel;
  Button(int x, int y, int w, int h, int r, String label, PFont font, int fontsize, boolean letterbox) {
    buttonX=x;
    buttonY=y;
    buttonW=w;
    buttonH=h;
    buttonR=r;
    buttonLabel=label;
    buttonFont=font;
    buttonFontsize=fontsize;
    isLetterBox=letterbox;
  }
  void Draw() { 
    if (hoverButton()) {
      if (isLetterBox) {
        fill(hoverColorLetterBox);
      }
      else {
        fill(hoverColorButton);
      }
    } 
    else {
      if (isLetterBox) {
        fill(normalColorLetterBox);
      }
      else {
        fill(normalColorButton);
      }
    }
    if (hoverButton() && isClicked()==true) {
      if (isLetterBox) {
        fill(clickedColorLetterBox);
      }
      else {
        fill(clickedColorButton);
      }
    }
    rect(buttonX, buttonY, buttonW, buttonH, buttonR);
    textAlign(CENTER);
    textFont(buttonFont);
    textSize(buttonFontsize);
    if (isLetterBox) {
      fill(labelColorLetterBox);
      text(buttonLabel, ((buttonX+buttonW/2)+1), ((buttonY+buttonH/2)+buttonFontsize/2)-11);
    }
    else {
      fill(labelColorButton);
      text(buttonLabel, ((buttonX+buttonW/2)+1), ((buttonY+buttonH/2)+buttonFontsize/2)-1);
    }
  }
  boolean hoverButton() {
    if (mouseX/scaleFactor >= buttonX && mouseX/scaleFactor <= buttonX+buttonW && mouseY/scaleFactor >= buttonY && mouseY/scaleFactor <= buttonY+buttonH) {
      return true;
    } 
    else {
      return false;
    }
  }
  boolean isClicked() {
    if (mouseX/scaleFactor >= buttonX && mouseX/scaleFactor <= buttonX+buttonW && mouseY/scaleFactor >= buttonY && mouseY/scaleFactor <= buttonY+buttonH && mousePressed) {
      return true;
    } 
    else {
      return false;
    }
  }
  boolean isLetterBoxClicked(int x, int y, int w, int h) {
    if (mouseX/scaleFactor >= x && mouseX/scaleFactor <= x+w && mouseY/scaleFactor >= y && mouseY/scaleFactor <= y+h && mousePressed) {
      return true;
    } 
    else {
      return false;
    }
  }
}

