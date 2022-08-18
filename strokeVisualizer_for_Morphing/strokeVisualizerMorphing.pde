import java.io.*;

ArrayList<CharStroke> targetChars = new ArrayList();
int g_iNumOfStroke = 0;

boolean redraw = false;
Button buttonClear;
String g_strSaveFileHeader = "";
int g_iSaveFileNumber = 0;

String[] strPrefix = {"0-9", "10-14", "15-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-"};
CharStroke[] strokes = new CharStroke[9];

color[] colors = {
  color(255, 100, 100), 
  color(100, 100, 255), 
  color(50, 150, 100), 
  color(250, 150, 100), 
  color(150, 50, 255), 
  color(0, 150, 55), 
  color(50, 50, 50)
};

String strDigit2(int num) {
  if (num < 10) return "0"+num;
  return str(num);
}

String strDigit(int num, int digit) {
  String retStr = str(num);
  digit--;
  while (digit > 0) {
    num /= 10;
    if (num == 0) retStr = "0" + retStr;
    digit--;
  }
  return retStr;
}

void resetSaveFileInfo() {
  g_strSaveFileHeader = year() + strDigit(month(), 2) + strDigit(day(), 2) + "_" + strDigit(hour(), 2)+strDigit(minute(), 2)+strDigit(second(), 2);
  g_iSaveFileNumber = 0;
}

void setup() {  
  size(3600, 3600);  
  //Start Change

  initFileDrop();
  resetSaveFileInfo();
  buttonClear = new Button(100, height-80, 200, 60, "Clear");
  buttonClear.display();
  textAlign(CENTER, CENTER);
  println("loading...");
  strokes[0] = createCharStrokeFromJSON(sketchPath()+"/json/0-9-0023.json");
  strokes[1] = createCharStrokeFromJSON(sketchPath()+"/json/10-14-0074.json");
  strokes[2] = createCharStrokeFromJSON(sketchPath()+"/json/15-19-0103.json");
  strokes[3] = createCharStrokeFromJSON(sketchPath()+"/json/20-29-0094.json");
  strokes[4] = createCharStrokeFromJSON(sketchPath()+"/json/30-39-0096.json");
  strokes[5] = createCharStrokeFromJSON(sketchPath()+"/json/40-49-0081.json");
  strokes[6] = createCharStrokeFromJSON(sketchPath()+"/json/50-59-0077.json");
  strokes[7] = createCharStrokeFromJSON(sketchPath()+"/json/60-69-0053.json");
  strokes[8] = createCharStrokeFromJSON(sketchPath()+"/json/70--0109.json");
  println("load finished");
}  

void displayResources() {
  buttonClear.display();
}

int morphingCounter = 0;

void draw() {
  if ( morphingCounter <= 4 * 8 ) {
    println("morphing process:", morphingCounter);
    background(255);
    fill(0);
    targetChars.clear();
    textSize(48);
    String strMorphing;
    if(morphingCounter / 4 == 8){
      strMorphing = strPrefix[morphingCounter / 4] + " (100%)";
    } else {
      strMorphing = strPrefix[morphingCounter / 4] + " (" + ((4-morphingCounter%4)*25) + "%), " + strPrefix[1 + morphingCounter / 4] + " (" +  ((morphingCounter % 4) * 25) + "%)";
    }
    for (int i=0; i<morphingCounter % 4; i++)  
      targetChars.add(strokes[1 + morphingCounter / 4]);
    for (int i = morphingCounter % 4; i < 4; i++)
      targetChars.add(strokes[morphingCounter / 4]);
    text( strMorphing, 850, height-50);

    morphingCounter++;
    CharStroke average = getAverageCharStroke(targetChars, g_iSaveFileNumber);
    stroke(0, 0, 0);
    average.displayStrokeByFourier(Config.g_iMultiple);
    println("save:", "img-morphing/" + strDigit(morphingCounter, 4) + ".png");
    saveFrame("img-morphing/" + strDigit(morphingCounter, 4) + ".png");
  }
}

void loadStrokeFile(String path) {
  println("add: " + path);
  CharStroke _charStroke = createCharStrokeFromJSON(path);
  if (_charStroke != null) {
    targetChars.add(_charStroke);
  }
  redraw = true;
}

void mousePressed() {
  if (buttonClear.inArea(new Point(mouseX, mouseY))) {
    targetChars.clear();
    resetSaveFileInfo();

    g_iNumOfStroke = 0;
    background(255);
    displayResources();
  }
}
