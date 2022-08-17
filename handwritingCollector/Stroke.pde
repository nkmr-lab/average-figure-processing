class Stroke {
  Point [] points;

  Stroke() {
    points = new Point[0];
  }

  Stroke(Point []_points) {
    points = _points;
  }

  void addPoint(Point _point) {
    points = (Point[])append(points, _point);
  }

  void displayStrokeOnCanvas(PGraphics Canvas) {
    Canvas.beginDraw();
    Canvas.strokeWeight(3);
    Canvas.stroke(0, 0, 200);
    for (int i=0; i<points.length-1; i++ ) {
      Canvas.line(points[i].x, points[i].y, points[i+1].x, points[i+1].y );
    }
    Canvas.endDraw();
  }

  Point getTailPoint() {
    if(points.length == 0) return new Point(0, 0);
    return points[points.length-1];
  }
}
