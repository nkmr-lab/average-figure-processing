import java.io.*;

// 下記のパスを差し替える
String g_strDataPath = "C:/Data/json_data/";

// バッチ処理用の命名規則とファイルマッチに関する正規表現
String[] strPrefix = {"all", "0-19", "20-39", "40-59", "60-", "0-9", "10-14", "15-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-"};
String[] strPattern = {"\\-", "0\\-9|10\\-14|15\\-19", "20\\-29|30\\-39", "40\\-49|50\\-59", "60\\-69|70\\-", "0\\-9", "10\\-14", "15\\-19", "20\\-29", "30\\-39", "40\\-49", "50\\-59", "60\\-69", "70\\-"};

ArrayList<CharStroke> allChars = new ArrayList();
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
  size(1200, 1200);

  resetSaveFileInfo();
  buttonClear = new Button(100, height-80, 200, 60, "Clear");
  buttonClear.display();
  textAlign(CENTER, CENTER);

  // jsonのファイル名に必ず-が入ってるので（ここのパターンはなんでもOK）
  loadStrokeFilesFromDir(g_strDataPath, "\\-");
  generateTargetStrokes(strPattern[g_iTargetPrefix]);
}  

void displayResources() {
  buttonClear.display();
}

int g_iTargetPrefix = 0;

void draw() {
  if (targetChars.size() > 0 && redraw) {
    background(255);
    fill(0);
    boolean bSave = false;
    if (g_iSaveFileNumber < targetChars.size()) {
      g_iSaveFileNumber = targetChars.size();
      bSave = true;
    }
    textSize(48);
    String strType = strPrefix[g_iTargetPrefix];
    text(strType + " (N=" + g_iSaveFileNumber + ")", 850, height-50);
    println(strType, g_iSaveFileNumber);

    for (int i=0; i<g_iSaveFileNumber; i++) {
      stroke(colors[i%colors.length]);
      targetChars.get(i).displayStroke();
    }

    if (g_iSaveFileNumber <= targetChars.size() || bSave == true) {
      CharStroke average = getAverageCharStroke(targetChars, g_iSaveFileNumber);
      stroke(0, 0, 0);
      average.displayStrokeByFourier(Config.g_iMultiple);

      println("save:", "image/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".png");
      saveFrame("image/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".png");

      println("save json", "json/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".json");
      average.saveStrokes("json/" + strType + "-" + strDigit(g_iSaveFileNumber, 4) + ".json");
      g_iTargetPrefix++;
      targetChars.clear();
      g_iSaveFileNumber = 0;

      if (g_iTargetPrefix < strPattern.length) {
        generateTargetStrokes(strPattern[g_iTargetPrefix]);
      }
    }

    displayResources();
  }
}

void generateTargetStrokes(String strMatch) {
  for (int i=0; i<allChars.size(); i++) {
    CharStroke _charStroke = (CharStroke)allChars.get(i);
    String[] m = match(_charStroke.path, strMatch);
    if ( m != null ) {
      println(strMatch, _charStroke.path);
      targetChars.add(_charStroke);
    }
  }
}

void loadStrokeFilesFromDir(String dir, String strMatch) {
  File directory = new File(dir);
  File[] files = directory.listFiles();   //ディレクトリ内の全てのファイル(ディレクトリも含む)を取得
  for (int i = 0; i < files.length; i++) {
    //println(files[i].getAbsolutePath());
    String[] m = match(files[i].getAbsolutePath(), strMatch);
    if ( m != null ) {
      //println(files[i].getAbsolutePath());
      loadStrokeFile(files[i].getAbsolutePath());
    }
  }
}

void loadStrokeFile(String path) {
  println("add: " + path);
  CharStroke _charStroke = createCharStrokeFromJSON(path);
  if (_charStroke != null) {
    allChars.add(_charStroke);
    //targetChars.add(_charStroke);
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
