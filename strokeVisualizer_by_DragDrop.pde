import java.io.*;

ArrayList<CharStroke> targetChars = new ArrayList();
int g_iNumOfStroke = 0;

boolean redraw = false;
Button buttonClear;
String g_strSaveFileHeader = "";
int g_iSaveFileNumber = 0;

color[] colors = {
  color(255, 100, 100),
  color(100, 100, 255),
  color(50, 150, 100),
  color(250, 150, 100),
  color(150, 50, 255),
  color(0, 150, 55),
  color(50, 50, 50)
};

String strDigit2(int num){
  if(num < 10) return "0"+num;
  return str(num);
}

String strDigit(int num, int digit){
  String retStr = str(num);
  digit--;
  while(digit > 0){
    num /= 10;
    if(num == 0) retStr = "0" + retStr;
    digit--;
  }
  return retStr;
}

void resetSaveFileInfo(){
  g_strSaveFileHeader = year() + strDigit(month(),2) + strDigit(day(),2) + "_" + strDigit(hour(),2)+strDigit(minute(),2)+strDigit(second(),2);
  g_iSaveFileNumber = 0;
}

void setup() {  
  size(1000, 1000);
  //Start Change

  initFileDrop();
  resetSaveFileInfo();
  buttonClear = new Button(100, height-80, 200, 60, "Clear");
  buttonClear.display();
  textAlign(CENTER, CENTER);
}  

void displayResources() {
  buttonClear.display();
}

void draw() {
  if (targetChars.size() > 0 && redraw) {
    background(255);
    fill(0);
    boolean bSave = false;
    if(g_iSaveFileNumber < targetChars.size()){
      g_iSaveFileNumber ++;
      bSave = true;
    }
    textSize(48);
    String strType = "target_name";
    text(strType + " (N=" + g_iSaveFileNumber + ")", 850, height-50);

    // 他のストロークの可視化
    for (int i=0; i<g_iSaveFileNumber; i++) {
      stroke(colors[i%colors.length]);
      targetChars.get(i).displayStroke();
    }
    
    CharStroke average = getAverageCharStroke(targetChars, g_iSaveFileNumber);
    stroke(0, 0, 0);
    average.displayStrokeByFourier(Config.g_iMultiple);
    if(g_iSaveFileNumber <= targetChars.size() || bSave == true){
      println(g_iSaveFileNumber, targetChars.size());
      File file = new File(sketchPath()+"/img-" + strType + "/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".png");
      if(file.exists()==false){
        println("not found", "img-" + strType + "/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".png");
        saveFrame("img-" + strType + "/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".png");
      }
    }
    displayResources();
  }
}

void loadStrokeFile(String path) {
  println("add: " + path);
  CharStroke _charStroke = createCharStrokeFromJSON(path);
  if (_charStroke != null){
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
