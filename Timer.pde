class Timer {
  int startTime;
  int countdownTime; // Aantal seconden voor de countdown timer
  int TimerX, TimerY; 
  Timer(int x, int y, int seconden) {
    TimerX = x;
    TimerY = y;
    countdownTime = seconden;
  }
  String currentTime() {
    int time = (countdownTime - ((millis() - startTime)) / 1000);
    int min = (time / 60);
    int sec = (time - (60 * min));
    if (time > 0) {
      if (time >= 60) {
        return min + "min, "+ sec + "sec";
      }
      else {
        return sec + "sec";
      }
    }
    else {
      if (currentState == IN_GAME) {
        currentState = GAME_OVER;
      }
      return "Game Over";
    }
  }
  void start() {
    startTime = millis();
  }
  void restart() {
    start();
  }
  void DisplayTime() {
    text(currentTime(), TimerX, TimerY);
  }
}

