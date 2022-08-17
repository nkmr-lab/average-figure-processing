class Point {
  float x;
  float y;

  Point() {
    x = 0.0;
    y = 0.0;
  }

  Point( float _x, float _y ) {
    x = _x;
    y = _y;
  }
}


Point getCurrentMousePosition() {
  return new Point(mouseX, mouseY);
}
