Canvas canvas;
Button save;
Button reset;
Button button_left;
Button button_right;
Button button_return;

Button[] button_age = new Button [9];
String[] strAge = {"9才以下", "10才～14才", "15才～19才", "20代", "30代", "40代", "50代", "60代", "70才以上"};
String[] strAgePrefix = {"0-9", "10-14", "15-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-"}; 

PFont buttonFont;
static int SELECT_AGE   = 0;
static int SELECT_HAND  = 1;
static int HAND_WRITING = 2;
static int THANK_YOU    = 3;

String[] strHandPrefix = {"left", "right"};
static int LEFT_HAND = 0;
static int RIGHT_HAND = 1;
int which_hand = -1;
int which_age = -1;

int step = SELECT_AGE;
int timeKeeper = 0;

int mode = 1; // 0 -> normal, 1 -> older

void setup() {
  //size(800, 800);
  size(1200, 1200);

  background(255);
  textAlign(CENTER, CENTER);
  
  initSettings();
}


void drawProcessing() {
  if (step == SELECT_AGE) {
    drawForSelectAge();
  } else if (step == SELECT_HAND) {
    drawForSelectHand();
  } else if (step == HAND_WRITING) {
    drawForWriting();
  } else if (step == THANK_YOU) {
    drawForThankyou();
  }
}

void drawForSelectHand() {
  background(255);
  fill(0);
  if (mode == 0) {
    textSize(48);
  } else {
    textSize(64);
  }
  text("どちらの手で書きますか？", width/2, height/3);
  button_left.display();
  button_right.display();
  button_return.display();
}

void drawForSelectAge() {
  background(255);
  fill(0);
  if (mode == 0) {
    textSize(36);
  } else {
    textSize(64);
  }
  text("何才（なんさい）か選択してください", width/2, 60);
  for (int i=0; i<button_age.length; i++) {
    button_age[i].display();
  }
}

void drawForWriting() {
  //background(100);
  fill(255);
  canvas.show();
  canvas.drawAxisGrid();
  if(mode == 0){
    textSize(32);
    text("「あ」を書いて「ほぞん」ボタンを押してください", width/2, 50);
  } else {
    textSize(64);
    text("「あ」を書いて\n「ほぞん」ボタンを押してください", width/2, 100);    
  }
  save.display();
  reset.display();
}

void drawForThankyou() {
  background(255);
  background(255);
  fill(0);
  if (mode == 0) {
    textSize(48);
    text("ありがとうございました", width/2, height/3);
    textSize(36);
    text("画面をペンでタッチすると次の人に進みます", width/2, height*2/3);
  } else {
    textSize(64);
    text("ありがとうございました", width/2, height/3);
    textSize(48);
    text("画面をペンでタッチすると次の人に進みます", width/2, height*2/3);
  }
}

void initSettings(){
  if (mode == 0) {
    buttonFont = loadFont("RictyDiminished-Bold-32.vlw");
    textFont(buttonFont, 32);
  } else {
    buttonFont = loadFont("RictyDiminished-Bold-64.vlw");
    textFont(buttonFont, 64);
  }

  if (mode == 0) {
    canvas = new Canvas(100, 100, 600, 600);
  } else {
    canvas = new Canvas(200, 200, 800, 800);
  }
  canvas.hide();
  registerMethod("mouseEvent", canvas);

  if (mode == 0) {
    save = new Button(500, height-80, 200, 50, "ほぞん");
    reset = new Button(100, height-80, 200, 50, "かきなおし", color(255, 50, 50));
  } else {
    save = new Button(650, height-180, 350, 120, "ほぞん");
    reset = new Button(200, height-180, 350, 120, "かきなおし", color(255, 50, 50));
  }

  save.hide();
  reset.hide();

  for (int i=0; i<9; i++) {
    if (mode == 0) {
      button_age[i] = new Button(200, 140+i*70, 400, 50, strAge[i], color(255, 100, 100));
    } else {
      button_age[i] = new Button(350, 140+i*110, 500, 100, strAge[i], color(255, 100, 100));
    }
    button_age[i].hide();
  }

  if (mode == 0) {
    button_left  = new Button(180, height/2, 160, 100, "ひだりて\n左手", color(255, 100, 100));
    button_right = new Button(480, height/2, 160, 100, "みぎて\n右手", color(255, 100, 100));
    button_return = new Button(330, height*3/4, 150, 50, "もどる", color(0, 0, 255));
  } else {
    button_left  = new Button(250, height/3+150, 300, 160, "ひだりて\n左手", color(255, 100, 100));
    button_right = new Button(600, height/3+150, 300, 160, "みぎて\n右手", color(255, 100, 100));
    button_return = new Button(450, height*3/4, 250, 160, "もどる", color(0, 0, 255));
  }
  drawForSelectAge();
  println("Initialized");
}


void mousePressed() {
  if (step == SELECT_AGE) {
    boolean selected = false;
    for (int i=0; i<button_age.length; i++) {
      if (button_age[i].clicked(mouseX, mouseY)) {
        which_age = i;
        selected = true;
      }
    }
    if (selected) {
      step = SELECT_HAND;
    }
  } else if (step == SELECT_HAND) {
    if (button_left.clicked(mouseX, mouseY)) {
      which_hand = LEFT_HAND;
      step = HAND_WRITING;
    } else if (button_right.clicked(mouseX, mouseY)) {
      which_hand = RIGHT_HAND;
      step = HAND_WRITING;
    } else if (button_return.clicked(mouseX, mouseY)) {
      step = SELECT_AGE;
    } else {
      return;
    }
  } else if (step == HAND_WRITING) {
    if (reset.clicked(mouseX, mouseY)) {
      println("Reset");
      canvas.reset();
    } else if (save.clicked(mouseX, mouseY)) {
      // 連続保存防止のため2secあける
      saveStrokes();
      canvas.reset();
      canvas.hide();
      save.hide();
      reset.hide();
      step = THANK_YOU;
    } else {
      return;
    }
  } else if (step == THANK_YOU) {
    step = SELECT_AGE;
  }
  drawProcessing();
}

void draw() {
}

void saveStrokes() {
  if (canvas.strokes.size() != 0) {
    CharStroke chSt = new CharStroke("");
    chSt.setStrokes(canvas.strokes);
    String filename = "save/handwriting_" + strHandPrefix[which_hand] + "_" + strAgePrefix[which_age] + "_" + time2str();
    chSt.saveStrokes(filename);
    println("Saved");
    timeKeeper = millis();
  }
}

String digit2(int data)
{
  if (data < 10) return "0" + data;
  else return str(data);
}

String digit3(int data)
{
  if (data < 10) return "00" + data;
  else if (data < 100) return "0" + data;
  else return str(data);
}

String time2str() {
  return str(year()) + digit2(month()) + digit2(day()) + "_" + digit2(hour()) + digit2(minute()) + digit2(second()) + digit3(millis()%1000);
}
