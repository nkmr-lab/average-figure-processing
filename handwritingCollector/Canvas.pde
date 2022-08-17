public class Canvas {
  Point start;
  Point size;
  ArrayList<Stroke> strokes;
  Stroke currentStroke;
  boolean writing;
  boolean show;

  Canvas(int _w, int _h) {
    init(0, 0, _w, _h);
  }

  Canvas(float _startX, float _startY, int _w, int _h) {
    init(_startX, _startY, _w, _h);
  }

  void init(float _startX, float _startY, int _w, int _h) {
    start = new Point(_startX, _startY);
    size = new Point(_w, _h);
    strokes = new ArrayList();
    writing = false;
    drawAxisGrid();
  }
  
  void show(){
    show = true;
  }

  void drawAxisGrid() {
    if(show == true){
      stroke(0);
      strokeWeight(3);
      background(150);
      fill(255);
      rect(start.x, start.y, size.x, size.y);
    }
  }
  
  void hide(){
    show = false;
  }

  void reset() {
    strokes = new ArrayList();
    writing = false;
    drawAxisGrid();
  }

  void mouseEvent(MouseEvent event) {
    //println(event);
    if(step == HAND_WRITING){
      if (inArea(getCurrentMousePosition())) {
        switch(event.getAction()) {
        case MouseEvent.PRESS:
          if (!writing) {
            writing = true;
            currentStroke = new Stroke();
            currentStroke.addPoint(getCurrentMousePositionOnCanvas());
          }
          break;
        case MouseEvent.DRAG:
          // Add point on stroke
          if (isMoved() && writing) {
            Point previousPoint = currentStroke.getTailPoint();
            currentStroke.addPoint(getCurrentMousePositionOnCanvas());
            Point currentPoint = currentStroke.getTailPoint();
            drawLineOnWindow(previousPoint, currentPoint);
          }
          break;
        case MouseEvent.RELEASE:
          if (writing) {
            strokes.add(currentStroke);
            writing =  false;
          }
          break;
        }
      } else if (writing) {
        // If cursor moved out of area, stop to add points
        strokes.add(currentStroke);
        writing =  false;
      }
    }
  }

  void drawLineOnWindow(Point from, Point to) {
    from = pointOnWindow(from);
    to = pointOnWindow(to);
    stroke(0, 0, 200);
    strokeWeight(3);
    line(from.x, from.y, to.x, to.y);
  }

  Point getCurrentMousePositionOnCanvas() {
    Point current = getCurrentMousePosition();
    return new Point(current.x - start.x, current.y - start.y);
  }

  Point pointOnWindow(Point _point) {
    return new Point(_point.x + start.x, _point.y + start.y);
  }

  boolean inArea(Point _point) {
    return start.x < _point.x && _point.x < start.x + size.x && start.y < _point.y && _point.y < start.y + size.y;
  }

  boolean isMoved() {
    if(currentStroke == null) return false;
    Point tail = currentStroke.getTailPoint();
    Point mouse = getCurrentMousePositionOnCanvas();
    return mouse.x != tail.x && mouse.y != tail.y;
  }
}
