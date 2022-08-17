
// implemented by matasuna, modified by nakamura
void saveHandwiting(String _filename, ArrayList<Stroke> _m_Strokes, String _character) {
  _filename+=".json";
  JSONObject HandwritingJSON;//保存する情報そのもの
  JSONArray strokesJSON;//複数画の情報を保存

  /*環境依存の変数*/
  int magnification;
  int default_double_back_margin;

  /*環境依存の変数*/
  magnification = 200;
  default_double_back_margin = 16;

  strokesJSON = new JSONArray();//strokeの集まり配列をstrokesにする
  HandwritingJSON = new JSONObject();//吐き出すファイル

  //_charstrokeクラスの情報をすべて引きずり出しjsonで保存する
  HandwritingJSON.setString("character", _character);//書かれている文字情報
  HandwritingJSON.setInt("strokeLength", _m_Strokes.size());

  for (Stroke _stroke : _m_Strokes) {//_m_Strokesに登録サれてる画数分回す
    JSONObject strokeJSON = new JSONObject();//1画分が入る

    /***********/
    //オリジナルpointを保存する
    //origpointを_stroke.m_orgPtに書き換え必要
    JSONArray points = savePoints(_stroke.points);
    strokeJSON.setJSONArray("points", points);
    /***********/

    //1画を確定して保存
    strokesJSON.append(strokeJSON);
  }
  HandwritingJSON.setJSONArray("strokes", strokesJSON);
  saveJSONObject(HandwritingJSON, _filename);
}

JSONArray savePoints(Point[] _points) {
  JSONArray points = new JSONArray();
  for (Point _point : _points) {
    JSONObject point = new JSONObject();
    point.setFloat("x", _point.x);
    point.setFloat("y", _point.y);
    points.append(point);
  }
  return points;
}
