import ddf.minim.*; // Geluiden
// OBJECTEN
Minim minim;
AudioSnippet buttonclick, letterboxclick, menubuttonclick, found, error;
AudioPlayer Music;
Timer CountDownTimer;
Button PlayButton, OptionsButton, InstructionsButton, ExitButton, MainMenuButton, MainMenuButton2, ResetButton, RetryButton, EnterButton, BackSpaceButton, LetterBoxes, SoundButton, MusicButton, ResetHSButton, langButton1, langButton2, langButton3;
// VARIABELEN
int COLS = 4, ROWS = 4, language, fps = 60, currentState, clicks, debugId, score, highScore, musicOn, soundOn;
float scaleFactor;
String state, line, input = "", inputFeedback = "";
String[] words, text;
boolean[][] selected = new boolean[COLS][ROWS];
char[][] board = new char[COLS][ROWS];
char[][] cloned = new char[COLS][ROWS];
StringList validWords = new StringList();
ArrayList<String> foundWords = new ArrayList<String>();
ArrayList<Integer> woordWaarde = new ArrayList<Integer>();
ArrayList <LetterFrequency> letter_frequencys = new ArrayList(); 
ArrayList <Character> lettersForStart = new ArrayList(); 
BufferedReader reader;
PrintWriter output;
// CONSTANTEN
final String GAME_VERSION = "1.9";
final boolean DEBUG = false;
final boolean sketchFullScreen() { // Set true voor fullscreen + size aanpassen!, false voor venster weergave.
  return true;
};
// TALEN
final int NEDERLANDS = 0; // Default
final int ENGELS = 1;
final int FRANS = 2;
// GameStates
final int MAIN_MENU = 0;
final int IN_GAME = 1;
final int GAME_OVER = 2;
final int OPTIONS_MENU = 3;
final int INSTRUCTIONS_MENU = 4;
// Fonts&Images
PFont Font, BoggleFont;
PImage menuImg1, refreshImg, backImg, selectedImg, langFlag1, langFlag2, langFlag3, imgPreferences, imgInstructions, musicOnImg, musicOffImg, soundOnImg, soundOffImg;

/**
 * setup() METHODE:
 * Hier worden alle instellingen uitgevoerd bij het opstarten van het programma.
 * Lettertypes worden hier ingeladen.
 * Knoppen en Timer worden hier aangemaakt (maar nog niet getekend, dit gebeurt in de draw() methode).
 */
public void setup() {
  orientation(LANDSCAPE); // Android scherm orientatie
  //size(1280, 720); // 16:9 formaat
  size(displayWidth, displayHeight); // Fullscreen formaat (enkel op 16:9 schermen gebruiken!)
  scaleFactor  = float(width) / 1280; // Het spel wordt geschaalt naargeland de grootte van het scherm.
  frameRate(fps);
  smooth();
  minim = new Minim(this);
  Music = minim.loadFile("sounds/music.mp3");
  buttonclick = minim.loadSnippet("sounds/buttonclick.mp3"); 
  letterboxclick = minim.loadSnippet("sounds/letterboxclick.mp3"); 
  menubuttonclick = minim.loadSnippet("sounds/menubuttonclick.mp3"); 
  found = minim.loadSnippet("sounds/found.mp3"); 
  error = minim.loadSnippet("sounds/error.mp3"); 
  // Lettertypes&Fotos aanmaken
  Font = createFont("MicrosoftSansSerif", 16, true);
  BoggleFont = createFont("font/boggle.ttf", 50);
  changeAppIcon(loadImage("img/icon.png"));
  menuImg1 = loadImage("img/boggle.png");
  refreshImg = loadImage("img/refresh.png");
  backImg = loadImage("img/back.png");
  selectedImg = loadImage("img/selected.png");
  langFlag1 = loadImage("img/BE.png");
  langFlag2 = loadImage("img/GB.png");
  langFlag3 = loadImage("img/FR.png");
  imgPreferences = loadImage("img/pref.png");
  imgInstructions = loadImage("img/instructions.png");
  soundOnImg = loadImage("img/soundon.png");
  soundOffImg = loadImage("img/soundoff.png");
  musicOnImg = loadImage("img/musicon.png");
  musicOffImg = loadImage("img/musicoff.png");
  // Initialisatie
  importHighscore(); // De highscore inladen van vorige sessie.
  importLanguage(); // De taal inladen van vorige sessie.
  importMusicSettings();
  Initialize();
}

public void Initialize()
{
  initializeLanguage();
  initializeLetterFrequency();
  // Objecten aanmaken
  CountDownTimer = new Timer(30, 190, 180);
  PlayButton = new Button(355, 250, 570, 85, 20, text[0], BoggleFont, 40, false);
  OptionsButton = new Button(355, 350, 570, 85, 20, text[1], BoggleFont, 40, false);
  InstructionsButton = new Button(355, 450, 570, 85, 20, text[2], BoggleFont, 40, false);
  ExitButton = new Button(355, 550, 570, 85, 20, text[3], BoggleFont, 40, false);
  MainMenuButton = new Button(15, 663, 200, 50, 10, text[8], BoggleFont, 24, false);
  MainMenuButton2 = new Button(650, 470, 420, 105, 10, text[8], BoggleFont, 50, false);
  ResetButton = new Button(240, 663, 200, 50, 10, "  " + text[9], BoggleFont, 25, false);
  ResetHSButton = new Button(51, 561, 125, 84, 5, "", BoggleFont, 25, false);
  RetryButton = new Button(215, 470, 420, 105, 10, text[16], BoggleFont, 50, false);
  EnterButton = new Button(840, 580, 405, 40, 10, "ENTER", BoggleFont, 25, false);
  BackSpaceButton = new Button(1190, 515, 55, 50, 5, "", BoggleFont, 11, false);
  MusicButton = new Button(627, 181, 70, 70, 5, "", BoggleFont, 11, false);
  SoundButton = new Button(717, 181, 70, 70, 5, "", BoggleFont, 11, false);
  langButton1 = new Button(51, 181, 125, 84, 5, "", BoggleFont, 11, false);
  langButton2 = new Button(51, 281, 125, 84, 5, "", BoggleFont, 11, false);
  langButton3 = new Button(51, 381, 125, 84, 5, "", BoggleFont, 11, false);
}

/**
 * draw() METHODE:
 * Alles binnen draw() wordt constant gerefeshed aan 60 Frames Per Seconde (FPS).
 * Hier komen dus al onze elementen die we willen tekenen. 
 * We maken hierbij gebruik van aparte methodes die we zelf aanmaken onderaan om de code overzichtelijker te houden. 
 */
public void draw() 
{  
  scale(scaleFactor); // Alles wordt hier geschaald
  background(241, 124, 31); //Achtergrondskleur
  if (musicOn==1 && !(Music.isPlaying())) { 
    Music.rewind();
    Music.play();
  }
  switch(currentState) { // Tekent enkel de objecten binnen de huidige state (Hoofdmenu, Ingame,...).
  case MAIN_MENU:
    state = "Mainmenu";
    mainMenu();
    break;
  case IN_GAME:
    state = "Ingame";
    drawPanels(); 
    drawLetterBoxes();
    drawGameText();
    break;
  case GAME_OVER:
    state = "Game over";
    gameOver();
    break;
  case OPTIONS_MENU:
    state = "Options";
    Options();
    break;
  case INSTRUCTIONS_MENU:
    state = "Instructions";
    Instructions();
    break;
  default:             
    stop();
    break;
  }
  if (DEBUG) { // Dit wordt enkel weergeven als bij variabelen DEBUG=true; is gezet.
    line(0, mouseY/scaleFactor, width, mouseY/scaleFactor);
    line(mouseX/scaleFactor, 0, mouseX/scaleFactor, height);
    drawCurrentVersion();
    drawCursorPosition();
    drawCurrentState();
    drawFPS();
  }
}

/**
 * mousePressed() MUISKLIK INPUT METHODE:
 * Binnen deze methode worden alle acties die moeten gebeuren, wanneer een knop van de MUIS wordt ingedrukt, verwerkt.
 */
public void mousePressed() 
{ 
  clicks++;
  Debug("Click: " + clicks + " || " + "X:" + floor(mouseX/scaleFactor) + ", Y:" + floor(mouseY/scaleFactor)); // Telkens wanneer we klikken en DEBUG=true worden de huidige coordinaten van de muis geprint in het debug venster onderaan.
  switch(currentState) { // Deze switch zorgt ervoor dat enkel de knoppen binnen de huidige state werken en bevatten de opdrachten waar de knoppen voor dienen.
  case MAIN_MENU:
    if (PlayButton.isClicked()) {
      Reset();
      currentState = IN_GAME;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    if (OptionsButton.isClicked()) {
      currentState = OPTIONS_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    if (InstructionsButton.isClicked()) {
      currentState = INSTRUCTIONS_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    if (ExitButton.isClicked()) {
      Debug("Exit-Button clicked.");
      Debug("Game shutting down.");
      exit();
    }
    break;
  case IN_GAME:
    if (MainMenuButton.isClicked()) {
      currentState = MAIN_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    if (BackSpaceButton.isClicked()) {
      backSpace();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (EnterButton.isClicked() && input.length() > 2) {
      checkInput();
    }
    if (ResetButton.isClicked()) {
      Reset();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }    
    for (int i = 0; i < COLS; i++) {
      for (int j = 0; j < ROWS; j++) {
        if (LetterBoxes.isLetterBoxClicked((270 + (133 * i)), (110 + (133 * j)), 128, 128)) {
          if (input.length() <= (ROWS * COLS)) {          
            input = input + str(board[i][j]);
          }
          if (soundOn==1) { 
            letterboxclick.rewind(); 
            letterboxclick.play();
          }
          return;
        }
      }
    }     
    break;
  case GAME_OVER:
    if (RetryButton.isClicked()) {
      Reset();      
      currentState = IN_GAME;
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (MainMenuButton2.isClicked()) {
      currentState = MAIN_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    break;
  case OPTIONS_MENU:
    if (MainMenuButton.isClicked()) {
      currentState = MAIN_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    if (langButton1.isClicked()) {
      language=NEDERLANDS;
      updateLanguage();
      Initialize();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (langButton2.isClicked()) {
      language=ENGELS;
      updateLanguage();
      Initialize();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (langButton3.isClicked()) {
      language=FRANS;
      updateLanguage();
      Initialize();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (ResetHSButton.isClicked()) {      
      highScore = 0; 
      output = createWriter(dataPath("highscore.dat"));
      output.print(highScore);
      output.flush();  
      output.close();
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (MusicButton.isClicked()) {    
      if (musicOn == 0) { 
        musicOn = 1; 
        Music.unmute();
      }
      else { 
        musicOn = 0; 
        Music.mute();
      }
      output = createWriter(dataPath("music.dat"));
      output.print(musicOn);
      output.flush();  
      output.close();;
      if (soundOn==1) { 
        buttonclick.rewind(); 
        buttonclick.play();
      }
    }
    if (SoundButton.isClicked()) {    
      if (soundOn == 0) {
        soundOn = 1;
      }
      else {
        soundOn = 0;
      }
      output = createWriter(dataPath("music.dat"));
      output.print(soundOn);
      output.flush();  
      output.close();
    }
    break;
  case INSTRUCTIONS_MENU:
    if (MainMenuButton.isClicked()) {
      currentState = MAIN_MENU;
      if (soundOn==1) { 
        menubuttonclick.rewind(); 
        menubuttonclick.play();
      }
    }
    break;
  default:
    break;
  }
}

/**
 * KeyPressed() TOETSENBORD INPUT METHODE:
 * Binnen deze Methode worden alle acties die moeten gebeuren, wanneer een knop van het TOETSENBORD wordt ingedrukt, verwerkt.
 */
public void keyPressed() 
{
  switch(currentState) {
  case IN_GAME:
    if (key==BACKSPACE) { // Backspace-knop ingedrukt
      backSpace();
      if (soundOn == 1) {
        buttonclick.rewind(); 
        buttonclick.play();
      }
    } 
    else if ((key==ENTER || key==RETURN) && input.length() > 2) { // Enter-knop ingedrukt
      checkInput();
    }
    else if (((key >= 97 && key <= 122)||(key >= 65 && key <= 90)) && input.length() <= (ROWS * COLS)) { // Enkel letters mogen worden ingevoerd kleine letters (97-122) en hoofdletters (65-90)
      input = (input + key).toUpperCase();
      letterboxclick.rewind(); 
      letterboxclick.play();
    }
    break;
  }
}

void stop() 
{
  Music.close();
  minim.stop();
  super.stop();
}

public void backSpace() 
{ // Als men op backspace drukt of op "<--" klikt
  if (input.length() > 0) {
    input = input.substring(0, input.length() - 1);
    if (soundOn==1) { 
      buttonclick.rewind(); 
      buttonclick.play();
    }
  }
}

public void checkInput() 
{ // Checkt wat men ingevuld heeft
  int index = -1;
  boolean alreadyfound=false;
  for (int q = 0; q < validWords.size(); q++) {
    if (input.equals(validWords.get(q))) {
      index = q;
    }
  }
  for (int s = 0; s < foundWords.size(); s++) {
    if (input.equals(foundWords.get(s))) {
      alreadyfound=true;
    }
  }
  if (index >= 0 && alreadyfound == false) {
    Debug("Woord gevonden: " + input);
    inputFeedback=text[10] + input;
    foundWords.add(input);
    if (soundOn==1) { 
      found.rewind(); 
      found.play();
    }
    if (input.length() >= 8) { // Checkt de lengte van het woord en voegt de gepaste score toe
      woordWaarde.add(11);
      score += 11;
    }
    else {
      switch(input.length()) {
      case 3:
        woordWaarde.add(1);
        score += 1;
        break;
      case 4:
        woordWaarde.add(1);
        score += 1;
        break;
      case 5:
        woordWaarde.add(2);
        score += 2;
        break;
      case 6:
        woordWaarde.add(3);
        score += 3;
        break;
      case 7:
        woordWaarde.add(5);
        score += 5;
        break;
      default:
        woordWaarde.add(0);
        score += 0;
        break;
      }
    }
  }
  else if (alreadyfound == true) {
    Debug("Woord is al gevonden: " + input);
    inputFeedback=text[11] + input;
    if (soundOn==1) { 
      error.rewind(); 
      error.play();
    }
  }
  else {
    Debug("Ongeldig woord: " + input);
    inputFeedback=text[12] + input;
    if (soundOn==1) { 
      error.rewind(); 
      error.play();
    }
  }
  input = "";
}

public void importMusicSettings() 
{
  File file = new File(dataPath("music.dat"));
  if (!file.exists()) {
    output = createWriter(dataPath("music.dat"));
    output.print("0"); //Muziek uit standaard
    output.flush();  
    output.close();
  }
  reader = createReader(dataPath("music.dat"));
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (!(line == null)) {
    musicOn = int(line);
  }
  File file2 = new File(dataPath("sound.dat"));
  if (!file2.exists()) {
    output = createWriter(dataPath("sound.dat"));
    output.print("1"); // Geluiden aan standaard
    output.flush();  
    output.close();
  }
  reader = createReader(dataPath("sound.dat"));
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (!(line == null)) {
    soundOn = int(line);
  }
}

public void importHighscore() 
{
  File file = new File(dataPath("highscore.dat"));
  if (!file.exists()) {
    output = createWriter(dataPath("highscore.dat"));
    output.print(highScore);
    output.flush();  
    output.close();
  }
  reader = createReader(dataPath("highscore.dat"));
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (!(line == null)) {
    highScore = int(line);
  }
}
public void importLanguage() 
{
  File file = new File(dataPath("language.dat"));
  if (!file.exists()) {
    output = createWriter(dataPath("language.dat"));
    output.print(language);
    output.flush();  
    output.close();
  }
  reader = createReader(dataPath("language.dat"));
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  if (!(line == null)) {
    language = int(line);
  }
}

public void updateSettings() 
{ 
  output = createWriter(dataPath("music.dat"));
  output.print(musicOn);
  output.flush();  
  output.close();
  output = createWriter(dataPath("sound.dat"));
  output.print(soundOn);
  output.flush();  
  output.close();
}

public void updateHighscore() 
{
  if (highScore < score) {
    highScore = score; 
    output = createWriter(dataPath("highscore.dat"));
    output.print(highScore);
    output.flush();  
    output.close();
  }
}

public void updateLanguage() 
{ 
  output = createWriter(dataPath("language.dat"));
  output.print(language);
  output.flush();  
  output.close();
}

public void initializeLanguage() 
{
  defineLetters();
  switch(language) { // Laadt de juiste woordenbibliotheek (*.dic) naar geland de ingestelde taal.
  case NEDERLANDS: 
    text = new String[] {
      "Spelen", "Opties", "Instructies", "Verlaten", "TIMER:", "PUNTEN:", "GEVONDEN:", "Gevonden woorden:", "Hoofdmenu", "Reset", "Woord gevonden: ", "Woord is al gevonden: ", "Ongeldig woord: ", "Maak een woord en druk op Enter.", "Letters:", "Punten:", "Opnieuw", "Behaalde score: ", "Topscore: ", "Taal:", "Nederlands", "Engels", "Frans", "Highscore resetten:", "Geluiden:"
    };
    words = loadStrings("dics/dutch.dic");
    //print(words);
    break;
  case ENGELS:
    text =  new String[] {
      "Play", "Options", "Instructions", "Exit", "TIMER:", "SCORE:", "FOUND:", "WORDS FOUND:", "Main Menu", "Reset", "Word Found: ", "Word already found: ", "Invalid word: ", "Make a word and press Enter.", "Letters:", "Points:", "Retry", "Score achieved: ", "Highscore: ", "Language:", "Dutch", "English", "French", "Reset Highscore:", "Sounds:"
    };
    words = loadStrings("dics/english.dic");
    break;
  case FRANS: 
    text =  new String[] {
      "Jouer", "Options", "Instructions", "Exit", "TIMER:", "POINTS:", "TROUVES:", "Mots trouves:", "Menu", "Reset", "Mot trouve: ", "Mot a ete trouve: ", "Mot incorrect: ", "Faire un mot et appuyez sur Entree", "Lettres:", "Points:", "Refaire", "Score atteint: ", "Meilleur score: ", "Language:", "Neerlandais", "Anglais", "Francais", "Reinitialiser meilleurs score:", "Audio:"
    };
    words = loadStrings("dics/french.dic");
    break;
  }
}

public void defineLetters() 
{
  switch(language) {
  case NEDERLANDS: // nederlands
    letter_frequencys.add (new LetterFrequency ('a', 7.486)); 
    letter_frequencys.add (new LetterFrequency ('b', 1.584)); 
    letter_frequencys.add (new LetterFrequency ('c', 1.242)); 
    letter_frequencys.add (new LetterFrequency ('d', 5.933)); 
    letter_frequencys.add (new LetterFrequency ('e', 18.914)); 
    letter_frequencys.add (new LetterFrequency ('f', 0.805)); 
    letter_frequencys.add (new LetterFrequency ('g', 3.403)); 
    letter_frequencys.add (new LetterFrequency ('h', 2.380)); 
    letter_frequencys.add (new LetterFrequency ('i', 6.499)); 
    letter_frequencys.add (new LetterFrequency ('j', 1.461)); 
    letter_frequencys.add (new LetterFrequency ('k', 2.248)); 
    letter_frequencys.add (new LetterFrequency ('l', 3.568)); 
    letter_frequencys.add (new LetterFrequency ('m', 2.213)); 
    letter_frequencys.add (new LetterFrequency ('n', 10.032)); 
    letter_frequencys.add (new LetterFrequency ('o', 6.063)); 
    letter_frequencys.add (new LetterFrequency ('p', 1.370)); 
    letter_frequencys.add (new LetterFrequency ('q', 0.009)); 
    letter_frequencys.add (new LetterFrequency ('r', 6.411)); 
    letter_frequencys.add (new LetterFrequency ('s', 5.733)); 
    letter_frequencys.add (new LetterFrequency ('t', 6.923)); 
    letter_frequencys.add (new LetterFrequency ('u', 2.192)); 
    letter_frequencys.add (new LetterFrequency ('v', 1.854)); 
    letter_frequencys.add (new LetterFrequency ('w', 1.821)); 
    letter_frequencys.add (new LetterFrequency ('x', 0.036)); 
    letter_frequencys.add (new LetterFrequency ('y', 0.035)); 
    letter_frequencys.add (new LetterFrequency ('z', 1.374));
    break;
  case ENGELS: // engels
    letter_frequencys.add (new LetterFrequency ('a', 8.167)); 
    letter_frequencys.add (new LetterFrequency ('b', 1.492)); 
    letter_frequencys.add (new LetterFrequency ('c', 2.782)); 
    letter_frequencys.add (new LetterFrequency ('d', 4.253)); 
    letter_frequencys.add (new LetterFrequency ('e', 12.702)); 
    letter_frequencys.add (new LetterFrequency ('f', 2.228)); 
    letter_frequencys.add (new LetterFrequency ('g', 2.015)); 
    letter_frequencys.add (new LetterFrequency ('h', 6.094)); 
    letter_frequencys.add (new LetterFrequency ('i', 6.966)); 
    letter_frequencys.add (new LetterFrequency ('j', 0.153)); 
    letter_frequencys.add (new LetterFrequency ('k', 0.772)); 
    letter_frequencys.add (new LetterFrequency ('l', 4.025)); 
    letter_frequencys.add (new LetterFrequency ('m', 2.406)); 
    letter_frequencys.add (new LetterFrequency ('n', 6.749)); 
    letter_frequencys.add (new LetterFrequency ('o', 7.507)); 
    letter_frequencys.add (new LetterFrequency ('p', 1.929)); 
    letter_frequencys.add (new LetterFrequency ('q', 0.095)); 
    letter_frequencys.add (new LetterFrequency ('r', 5.987)); 
    letter_frequencys.add (new LetterFrequency ('s', 6.327)); 
    letter_frequencys.add (new LetterFrequency ('t', 9.056)); 
    letter_frequencys.add (new LetterFrequency ('u', 2.758)); 
    letter_frequencys.add (new LetterFrequency ('v', 0.978)); 
    letter_frequencys.add (new LetterFrequency ('w', 2.360)); 
    letter_frequencys.add (new LetterFrequency ('x', 0.150)); 
    letter_frequencys.add (new LetterFrequency ('y', 1.974)); 
    letter_frequencys.add (new LetterFrequency ('z', 0.074));
    break;
  case FRANS: // frans
    letter_frequencys.add (new LetterFrequency ('a', 7.636)); 
    letter_frequencys.add (new LetterFrequency ('b', 0.901)); 
    letter_frequencys.add (new LetterFrequency ('c', 3.260)); 
    letter_frequencys.add (new LetterFrequency ('d', 3.669)); 
    letter_frequencys.add (new LetterFrequency ('e', 14.715)); 
    letter_frequencys.add (new LetterFrequency ('f', 1.066)); 
    letter_frequencys.add (new LetterFrequency ('g', 0.866)); 
    letter_frequencys.add (new LetterFrequency ('h', 0.737)); 
    letter_frequencys.add (new LetterFrequency ('i', 7.529)); 
    letter_frequencys.add (new LetterFrequency ('j', 0.545)); 
    letter_frequencys.add (new LetterFrequency ('k', 0.049)); 
    letter_frequencys.add (new LetterFrequency ('l', 5.456)); 
    letter_frequencys.add (new LetterFrequency ('m', 2.968)); 
    letter_frequencys.add (new LetterFrequency ('n', 7.095)); 
    letter_frequencys.add (new LetterFrequency ('o', 5.378)); 
    letter_frequencys.add (new LetterFrequency ('p', 2.521)); 
    letter_frequencys.add (new LetterFrequency ('q', 1.362)); 
    letter_frequencys.add (new LetterFrequency ('r', 6.553)); 
    letter_frequencys.add (new LetterFrequency ('s', 7.948)); 
    letter_frequencys.add (new LetterFrequency ('t', 7.244)); 
    letter_frequencys.add (new LetterFrequency ('u', 6.311)); 
    letter_frequencys.add (new LetterFrequency ('v', 1.628)); 
    letter_frequencys.add (new LetterFrequency ('w', 0.074)); 
    letter_frequencys.add (new LetterFrequency ('x', 0.427)); 
    letter_frequencys.add (new LetterFrequency ('y', 0.128)); 
    letter_frequencys.add (new LetterFrequency ('z', 0.326));
    break;
  }
}

public void initializeLetterFrequency() 
{
  for (LetterFrequency lett : letter_frequencys) {
    lett.howOftenToUse=int(lett.percent*10);
    if (lett.howOftenToUse<1) 
      lett.howOftenToUse=1;
  }
  for (LetterFrequency lett : letter_frequencys) {  
    char a1 = char(str(lett.letter).toUpperCase().charAt(0));
    for (int i = 0; i<lett.howOftenToUse; i++) {
      lettersForStart.add(a1);
    }
  }
}

/**
 * AANGEPASTE DEBUG METHODE:
 * Een aangepaste debug-output voor onderaan met extra informatie (duidelijker dan de gewone println).
 * Elke debug regel krijgt een eigen ID dat vooraan de regel getoond wordt.
 */
public void Debug(String debugText) 
{ 
  debugId++;
  if (DEBUG) {
    println(debugId + ": ||DEBUG|| " + debugText);
  }
}

/**
 * Methode om de huidige cursor coordinaten te tekenen (enkel bij DEBUG=true)
 */
public void drawCursorPosition() 
{ 
  String text = "X:" + floor(mouseX/scaleFactor) + ", Y:" + floor(mouseY/scaleFactor);
  fill(0);
  textAlign(RIGHT);
  textFont(Font);
  text(text, (width/scaleFactor)-10, (height/scaleFactor)-10);
}

/**
 * Methode die tekent waar we in het programma zitten (Hoofdmenu, ingame,...) (enkel bij DEBUG=true)
 */
public void drawCurrentState() {
  String text = "Current state: " + state;
  fill(0);
  textAlign(RIGHT);
  textFont(Font);
  text(text, (width / scaleFactor) - 10, 20);
  textAlign(CENTER);
  text("DEBUG MODE IS ON!", (width / scaleFactor) / 2, 20);
}

/**
 *Methode die de huide versie tekent (enkel bij DEBUG=true)
 */
public void drawCurrentVersion() 
{ 
  fill(0);
  textAlign(RIGHT);
  textFont(Font);
  text("v" + GAME_VERSION, (width / scaleFactor) - 10, 40);
}

/**
 * Methode die de framerate tekent (enkel bij DEBUG=true)
 */
public void drawFPS() 
{ 
  fill(0);
  textAlign(LEFT);
  textFont(Font);
  text("FPS:" + fps, 10, 20);
  text("Scale:" + scaleFactor + "x", 10, 40);
}

/**
 * Methode die alle panelen tekent ingame (gele panelen)
 */
public void drawPanels() 
{ 
  fill(254, 204, 8); 
  rect(0, 90, 250, 565); // Left-TextPanel
  rect(0, 0, 1280, 90); // Top-TextPanel  
  rect(0, 655, 1280, 65); // Bottom-TextPanel
  rect(815, 100, 455, 545, 4); // Right-Panel
  rect(260, 100, 545, 545, 7); // Gameboard-Panel
  noStroke();
  fill(246, 148, 24);
  rect(840, 175, 405, 325, 10); // WordsFound-Box
  stroke(0);
  EnterButton.Draw(); // Input-enterButton
  BackSpaceButton.Draw(); //BackSpace-Button
  fill(255);
  rect(840, 515, 340, 50); // Input-Box
  MainMenuButton.Draw(); // MainMenuButton
  ResetButton.Draw(); // ResetButton
}

/**
 * Methode die het raster en de letters tekent d.m.v. een loop te gebruiken
 */
public void drawLetterBoxes() 
{ 
  for (int i = 0; i < COLS; i++) {          
    for (int j = 0; j < ROWS; j++) {  
      LetterBoxes = new Button((270 + (133 * i)), (110 + (133 * j)), 128, 128, 4, str(board[i][j]), Font, 50, true);
      LetterBoxes.Draw();
      /*if (selected[i][j]) {
       fill(255, 0, 0, 127);
       rect((320+133*i), (110+133*j), 128, 128, 4);
       }*/
    }
  }
}

/**
 * Methode die alle tekst ingame tekent
 */
public void drawGameText() 
{ 
  fill(8, 126, 167);
  textAlign(LEFT);
  textFont(BoggleFont, 30);    
  text(text[7], 840, 150);
  textFont(BoggleFont, 20); 
  text(text[4], 20, 150);
  text(text[5], 20, 240);
  text(text[6], 20, 330);
  text(text[14], 840, 35);
  text(text[15], 840, 75);
  textFont(BoggleFont, 18); 
  text(inputFeedback, 840, 695);
  textFont(BoggleFont, 17);   
  int v = 0;
  int w = 860;
  for (int i = 0; i < foundWords.size(); i++) { // Gevonden woorden weergeven
    text(foundWords.get(i) + " (" + woordWaarde.get(i) + ")", w, 205 + (20 * v));
    if (!(v >= 14)) {
      v++;
    }
    else {
      v = 0;
      w = w + 130;
    }
  }
  textFont(BoggleFont, 60); 
  text("BOGGLE", 20, 70);
  fill(0);
  textFont(Font, 25);
  text(input + (frameCount / 30 % 2 == 0 ? "|" : ""), 850, 550); // Cursor na de getypte tekst laten knipperen
  fill(255);
  textFont(BoggleFont, 25); 
  text(score + " (" +  highScore + ")", 30, 280);
  CountDownTimer.DisplayTime(); // Timer weergeven
  text(str(foundWords.size()) + "/" + validWords.size(), 30, 370);
  image(refreshImg, 255, 678, 25, 25);
  image(backImg, 1198, 523, 35, 35);
  text("3", 970, 35);
  text("4", 1020, 35);
  text("5", 1070, 35);
  text("6", 1120, 35);
  text("7", 1170, 35);
  text("8+", 1220, 35);
  text("1", 970, 75);
  text("1", 1020, 75);
  text("2", 1070, 75);
  text("3", 1120, 75);
  text("5", 1170, 75);
  text("11", 1220, 75);
  strokeWeight(2);
  stroke(8, 126, 167);
  line(835, 5, 1265, 5);
  line(835, 45, 1265, 45);
  line(835, 85, 1265, 85);
  line(835, 5, 835, 85);
  line(1265, 5, 1265, 85);
  strokeWeight(1);
  stroke(0);
}

/**
 * Methode die alle hoofdmenu elementen tekent
 */
public void mainMenu() 
{ 
  fill(8, 126, 167);
  textAlign(LEFT);
  textFont(BoggleFont, 100);    
  text("BOGGLE", 310, 170);
  rect(335, 232, 610, 421, 10); // MenuPanel
  stroke(255); 
  PlayButton.Draw();
  OptionsButton.Draw();
  InstructionsButton.Draw();
  ExitButton.Draw();
  image(menuImg1, -50, 290, 360, 500);
  stroke(0);
}

/**
 * Methode die alle elementen tekent wanneer het game over is
 */
public void gameOver()
{
  fill(8, 126, 167);
  textAlign(LEFT);
  textFont(BoggleFont, 75);    
  text("GAME OVER", 257, 170);
  rect(180, 232, 920, 375, 10);
  fill(255);
  textAlign(LEFT);
  textFont(BoggleFont, 40);    
  text(text[17] + score, 215, 325);
  text(text[18] + highScore, 215, 385);
  MainMenuButton2.Draw();
  RetryButton.Draw();
  updateHighscore();
}

/**
 * Methode die alle opties elementen tekent
 */
public void Options() 
{ 
  fill(254, 204, 8); 
  rect(0, 0, (width / scaleFactor) - 1, 90); // Top-TextPanel
  rect(0, 655, 1280, 65); // Bottom-TextPanel
  image(imgPreferences, 1175, 15, 64, 64);
  fill(8, 126, 167);
  textAlign(LEFT);
  textFont(BoggleFont, 60); 
  text(text[1].toUpperCase(), 20, 70);
  textFont(BoggleFont, 45); 
  text(text[19], 20, 150);
  text(text[23] + " " + highScore, 20, 540);
  text(text[24], 600, 150);
  langButton1.Draw();
  langButton2.Draw();
  langButton3.Draw();
  ResetHSButton.Draw();
  SoundButton.Draw();
  MusicButton.Draw();
  MainMenuButton.Draw(); // MainMenuButton
  image(langFlag1, 50, 160, 128, 128);
  image(langFlag2, 50, 260, 128, 128);
  image(langFlag3, 50, 360, 128, 128);
  image(refreshImg, 83, 573, 64, 64);
  if (soundOn==1) {
    image(soundOnImg, 723, 184, 64, 64);
  }
  else {
    image(soundOffImg, 723, 184, 64, 64);
  }
  if (musicOn==1) {
    image(musicOnImg, 630, 184, 64, 64);
  }
  else {
    image(musicOffImg, 630, 184, 64, 64);
  } 
  textAlign(LEFT);
  textFont(BoggleFont, 25);
  switch(language) {
  case NEDERLANDS:
    fill(8, 126, 167);
    text(text[20], 200, 240);
    fill(255);
    text(text[21], 200, 340);
    fill(255);
    text(text[22], 200, 440);
    break;
  case ENGELS:
    fill(255);
    text(text[20], 200, 240);
    fill(8, 126, 167);
    text(text[21], 200, 340);
    fill(255);
    text(text[22], 200, 440);
    break;
  case FRANS:
    fill(255);
    text(text[20], 200, 240);
    fill(255);
    text(text[21], 200, 340);
    fill(8, 126, 167);
    text(text[22], 200, 440);
    break;
  }
  fill(255);
  text(text[9], 200, 610);
}

/**
 * Methode die alle instuctie elementen tekent
 */
public void Instructions() 
{
  fill(254, 204, 8); 
  rect(0, 0, (width / scaleFactor) - 1, 90); // Top-TextPanel
  rect(0, 655, 1280, 65); // Bottom-TextPanel
  image(imgInstructions, 1175, 15, 64, 64);
  fill(8, 126, 167);
  textAlign(LEFT);
  textFont(BoggleFont, 60); 
  text(text[2].toUpperCase(), 20, 70);
  switch(language) {
  case NEDERLANDS:
    textFont(BoggleFont, 45); 
    text("Hoe speel je het spel?", 20, 150);
    fill(255); 
    textFont(Font, 25);
    text("Je hebt 3 minuten de tijd om zoveel mogelijk punten te verzamelen door woorden te vormen met de letters", 40, 200);
    text("die je krijgt. Je mag de letters horizontaal, verticaal en diagonaal combineren. Elke gegeven letter mag je ", 40, 225);
    text("slechts eenmaal gebruiken. Het woord moet aan de volgende eisen voldoen:", 40, 250);
    text("- Het woord moet uit minimum 3 letters bestaan.", 70, 285);
    text("- Vervoegingen van werkwoorden zijn niet toegestaan.", 70, 310);
    text("- Afkortingen zijn niet toegestaan.", 70, 335);
    fill(8, 126, 167);
    textFont(BoggleFont, 45); 
    text("Puntenverdeling:", 20, 450);
    fill(255);
    textFont(Font, 25);
    text("Woord van 3 of 4 letters = 1 punt", 40, 500);
    text("Woord van 5 letters = 2 punten", 40, 525);
    text("Woord van 6 letters = 3 punten", 40, 550);
    text("Woord van 7 letters = 5 punten", 40, 575);
    text("Woord van 8 letters = 11 punten", 40, 600);
    break;
  case ENGELS:
    textFont(BoggleFont, 45); 
    text("How to play?", 20, 150);
    fill(255); 
    textFont(Font, 25);
    text("You got 3 minutes to earn as many points as possible by making words with the letters that are on the board.", 40, 200);
    text("You are allowed to combine letters horizontally, vertically and diagonally.", 40, 225);
    text("Every given letter may only be used once and the word must meet the following requirements:", 40, 250);
    text("- The word consists out of a minimum of 3 letters.", 70, 285);
    text("- Conjugations of verbs are not allowed.", 70, 310);
    text("- Abbreviations are not allowed.", 70, 335);
    fill(8, 126, 167);
    textFont(BoggleFont, 45); 
    text("Point distribution:", 20, 450);
    fill(255);
    textFont(Font, 25);
    text("Word of 3 or 4 letters = 1 point", 40, 500);
    text("Word of 5 letters = 2 points", 40, 525);
    text("Word of 6 letters = 3 points", 40, 550);
    text("Word of 7 letters = 5 points", 40, 575);
    text("Word of 8 letters = 11 points", 40, 600);
    break;
  case FRANS:
    textFont(BoggleFont, 45); 
    text("Comment jouer le jeu?", 20, 150);
    fill(255); 
    textFont(Font, 25);
    text("Vous avez 3 minutes pour recueillir autant de points en formant les lettres que vous obtenez mots. Vous", 40, 200);
    text("pouvez combiner les lettres horizontalement, verticalement ou en diagonale. Chaque point de données", 40, 225);
    text("peut être utilisé qu'une seule fois. Le mot doit répondre aux exigences suivantes:", 40, 250);
    text("- Le mot doit être composé d'un minimum de 3 caractères.", 70, 285);
    text("- La conjugaison des verbes ne sont pas autorisés.", 70, 310);
    text("- Les abréviations ne sont pas autorisés.", 70, 335);
    fill(8, 126, 167);
    textFont(BoggleFont, 45); 
    text("Distribution des points:", 20, 450);
    fill(255);
    textFont(Font, 25);
    text("Mot de 3 où 4 lettres = 1 point", 40, 500);
    text("Mot de 5 lettres = 2 points", 40, 525);
    text("Mot de 6 lettres = 3 points", 40, 550);
    text("Mot de 7 lettres = 5 points", 40, 575);
    text("Mot de 8 lettres = 11 points", 40, 600);
    break;
  }
  MainMenuButton.Draw(); // MainMenuButton
}

/**
 * Deze methode reset het spel (timer + nieuwe letters) en wordt geactiveerd bij het klikken op play of op de resetknop.
 */
public void Reset() 
{ 
  input = "";
  inputFeedback = text[13];
  score = 0;
  validWords.clear();
  foundWords.clear();
  woordWaarde.clear();
  for (int i = 0; i < COLS; i++) {          
    for (int j = 0; j < ROWS; j++) {  
      int posInArrayList = int(random(0, lettersForStart.size())); 
      char letter = char(lettersForStart.get(posInArrayList));
      board[i][j] = letter;
    }
  }
Found_Word_Already:
  for (int r = 0; r != words.length;) {
    final String w = words[r++];
    for (int i = board.length; i-- != 0; arrayCopy(board[i], cloned[i]));
    for (int x = 0; x != ROWS; ++x)  for (int y = 0; y != COLS;) {
      if (wordOnBoard(w, 0, x, y++, cloned)) {
        validWords.append(w);
        continue Found_Word_Already;
      }
    } 
    for (int n = r; n != words.length && words[n++].startsWith(w); ++r);
  }
  println("\n" + validWords);
  CountDownTimer.start();
}

/**
 * Algorithme die bepaalt of een bepaald woord op het bord uit de bibliotheek bestaat of niet.
 * URL: http://forum.processing.org/two/discussion/comment/13365
 */
public boolean wordOnBoard(String a, int s, int x, int y, char[][] b) 
{
  if (s == a.length())  return true;
  if ((x | y) < 0 || x >= b.length || y >= b[0].length
    || b[x][y] != a.charAt(s++))  return false;
  b[x][y] = '~'; 
  if (wordOnBoard(a, s, x-1, y-1, b))  return true;
  if (wordOnBoard(a, s, x-1, y, b))    return true;
  if (wordOnBoard(a, s, x-1, y+1, b))  return true;
  if (wordOnBoard(a, s, x, y-1, b))    return true;
  if (wordOnBoard(a, s, x, y+1, b))    return true;
  if (wordOnBoard(a, s, x+1, y-1, b))  return true;
  if (wordOnBoard(a, s, x+1, y, b))    return true; 
  return wordOnBoard(a, s, x+1, y+1, b);
}


/**
 * Zorgt voor het icoontje van het spel (niet voor Android!)
 */
public void changeAppIcon(PImage img) {
  final PGraphics pg = createGraphics(16, 16, JAVA2D);
  pg.beginDraw();
  pg.image(img, 0, 0, 16, 16);
  pg.endDraw();
  frame.setIconImage(pg.image); // Deze lijn als commentaar zetten als men voor Android compiled
}

/**
 * Klasse die de frequentie van letters bepaalt
 */
class LetterFrequency
{
  char letter;
  float percent;
  int howOftenToUse = 0;

  LetterFrequency(char A1, float Percent) {
    letter = A1;
    percent = Percent;
  }
}

