class Button {
  Point start;
  Point size;
  String text;
  color colour;
  boolean show;

  Button(float _startX, float _startY, int _w, int _h, String _text) {
    init(_startX, _startY, _w, _h, _text, color(50, 50, 255));
  }
  
  Button(float _startX, float _startY, int _w, int _h, String _text, color _c) {
    init(_startX, _startY, _w, _h, _text, _c);
  }

  void init(float _startX, float _startY, int _w, int _h, String _text, color _c) {
    start = new Point(_startX, _startY);
    size = new Point(_w, _h);
    text = _text;
    colour = _c;
  }
  
  void hide(){
    show = false;
  }

  void display(){
    show = true;
    stroke(0);
    strokeWeight(1);
    fill(colour);
    rect(start.x, start.y, size.x, size.y);
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(36);
    text(text, start.x+size.x/2, start.y+size.y/2);
  }
  
  boolean clicked(int mx, int my){
    if( !show ) return false;
    return inArea(getCurrentMousePosition()) && mousePressed;
    //return inArea(getCurrentMousePosition()) && mousePressed;
  }
  
  boolean inArea(Point _point) {
    if( !show ) return false;
    return start.x < _point.x && _point.x < start.x + size.x && start.y < _point.y && _point.y < start.y + size.y;
  }
    
}
